//
//  ClothDataSource.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation
import CodiveAPI

// MARK: - ClothDataSource Protocol

protocol ClothDataSource {
    func fetchClothItems(category: String?) async throws -> [ProductItem]
    
    /// 옷 저장 (Presigned URL 발급 → S3 업로드 → 옷 생성 API 호출)
    func saveClothes(inputs: [ClothInput], images: [Data]) async throws -> [Cloth]

    // MyCloset 전용 메서드
    func fetchMyClosetClothItems(
        categoryId: Int?,
        seasons: Set<Season>,
        searchText: String?
    ) async throws -> [Cloth]
    
    /// 옷 목록 조회 (API 연동)
    func fetchClothList(
        lastClothId: Int?,
        size: Int,
        categoryId: Int?,
        seasons: Set<Season>
    ) async throws -> (clothes: [Cloth], isLast: Bool)
    
    /// 옷 상세 조회 (API 연동)
    func fetchClothDetail(clothId: Int) async throws -> ClothDetailResult
    
    /// 옷 수정 (API 연동)
    func updateCloth(clothId: Int, request: ClothUpdateAPIRequest) async throws
    
    /// 옷 삭제 (API 연동) - 단일
    func deleteCloth(clothId: Int) async throws

    func deleteClothItems(_ clothIds: [Int]) async throws
    
    /// 룩북 전체 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO
}

// MARK: - DefaultClothDataSource

final class DefaultClothDataSource: ClothDataSource {

    // MARK: - Properties
    
    private let apiService: ClothAPIServiceProtocol
    
    // MARK: - Initializer
    
    init(apiService: ClothAPIServiceProtocol = ClothAPIService()) {
        self.apiService = apiService
    }

    // MARK: - Methods

    func fetchClothItems(category: String?) async throws -> [ProductItem] {
        // 전체 옷 목록 조회 (페이지네이션 없이 전체)
        let result = try await apiService.fetchClothes(
            lastClothId: nil,
            size: 100,
            categoryId: nil,
            seasons: []
        )

        return result.clothes.map { item in
            ProductItem(
                id: Int(item.clothId),
                imageUrl: item.imageUrl,
                brand: item.brand,
                name: item.name
            )
        }
    }

    /// 옷 저장 (전체 흐름: Presigned URL → S3 업로드 → 옷 생성)
    func saveClothes(inputs: [ClothInput], images: [Data]) async throws -> [Cloth] {
        guard inputs.count == images.count else {
            throw ClothDataSourceError.inputImageCountMismatch
        }

        let presignedInfos = try await apiService.getPresignedUrls(for: images)
        try await uploadImagesToS3(images: images, presignedInfos: presignedInfos)

        let createRequests = buildCreateRequests(inputs: inputs, presignedInfos: presignedInfos)
        let clothIds = try await apiService.createClothes(requests: createRequests)

        return try await fetchCreatedClothDetails(
            clothIds: clothIds, inputs: inputs, presignedInfos: presignedInfos
        )
    }

    private func uploadImagesToS3(images: [Data], presignedInfos: [PresignedUrlInfo]) async throws {
        for (imageData, presignedInfo) in zip(images, presignedInfos) {
            try await apiService.uploadImageToS3(
                presignedUrl: presignedInfo.presignedUrl,
                imageData: imageData,
                contentMD5: presignedInfo.md5Hash
            )
        }
    }

    private func buildCreateRequests(inputs: [ClothInput], presignedInfos: [PresignedUrlInfo]) -> [ClothCreateAPIRequest] {
        zip(inputs, presignedInfos).map { input, presignedInfo in
            ClothCreateAPIRequest(
                clothImageUrl: presignedInfo.finalUrl,
                clothUrl: input.purchaseUrl.isEmpty ? nil : input.purchaseUrl,
                name: input.name.isEmpty ? nil : input.name,
                brand: input.brand.isEmpty ? nil : input.brand,
                seasons: Array(input.seasons),
                categoryId: Int64(input.categoryId ?? 0)
            )
        }
    }

    private func fetchCreatedClothDetails(
        clothIds: [Int64], inputs: [ClothInput], presignedInfos: [PresignedUrlInfo]
    ) async throws -> [Cloth] {
        try await withThrowingTaskGroup(of: (Int, Cloth).self) { group in
            for (index, clothId) in clothIds.enumerated() {
                group.addTask {
                    await self.fetchOrFallback(
                        clothId: clothId, index: index,
                        input: inputs[index], presignedInfo: presignedInfos[index]
                    )
                }
            }

            var results: [(Int, Cloth)] = []
            for try await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }

    private func fetchOrFallback(
        clothId: Int64, index: Int, input: ClothInput, presignedInfo: PresignedUrlInfo
    ) async -> (Int, Cloth) {
        do {
            let detail = try await apiService.fetchClothDetails(clothId: clothId)
            let cloth = Cloth(
                id: Int(clothId), imageUrl: detail.clothImageUrl,
                name: detail.name, brand: detail.brand,
                purchaseUrl: detail.clothUrl,
                mainCategory: detail.parentCategory, subCategory: detail.category,
                seasons: Set(detail.seasons)
            )
            return (index, cloth)
        } catch {
            let cloth = Cloth(
                id: Int(clothId), imageUrl: presignedInfo.finalUrl,
                name: input.name.isEmpty ? nil : input.name,
                brand: input.brand.isEmpty ? nil : input.brand,
                purchaseUrl: input.purchaseUrl.isEmpty ? nil : input.purchaseUrl,
                mainCategory: nil, subCategory: nil, seasons: input.seasons
            )
            return (index, cloth)
        }
    }

    func fetchMyClosetClothItems(
        categoryId: Int?,
        seasons: Set<Season>,
        searchText: String?
    ) async throws -> [Cloth] {
        if let searchText = searchText, !searchText.isEmpty {
            // 검색어가 있으면 서버 사이드 검색 API 시도, 실패 시 클라이언트 필터링 fallback
            do {
                let result = try await apiService.searchClothes(
                    keyword: searchText,
                    size: 100,
                    categoryId: categoryId.map { Int64($0) },
                    seasons: Array(seasons)
                )
                return result.clothes.map(mapToCloth)
            } catch {
                let result = try await apiService.fetchClothes(
                    lastClothId: nil,
                    size: 100,
                    categoryId: categoryId.map { Int64($0) },
                    seasons: Array(seasons)
                )
                return result.clothes.map(mapToCloth).filter { cloth in
                    let nameMatch = cloth.name?.localizedCaseInsensitiveContains(searchText) ?? false
                    let brandMatch = cloth.brand?.localizedCaseInsensitiveContains(searchText) ?? false
                    return nameMatch || brandMatch
                }
            }
        } else {
            let result = try await apiService.fetchClothes(
                lastClothId: nil,
                size: 100,
                categoryId: categoryId.map { Int64($0) },
                seasons: Array(seasons)
            )
            return result.clothes.map(mapToCloth)
        }
    }

    func deleteClothItems(_ clothIds: [Int]) async throws {
        for clothId in clothIds {
            try await apiService.deleteCloth(clothId: Int64(clothId))
        }
    }

    // MARK: - API 연동 메서드

    func fetchClothList(
        lastClothId: Int?,
        size: Int,
        categoryId: Int?,
        seasons: Set<Season>
    ) async throws -> (clothes: [Cloth], isLast: Bool) {
        let result = try await apiService.fetchClothes(
            lastClothId: lastClothId.map { Int64($0) },
            size: Int32(size),
            categoryId: categoryId.map { Int64($0) },
            seasons: Array(seasons)
        )

        return (clothes: result.clothes.map(mapToCloth), isLast: result.isLast)
    }

    // MARK: - Private Helpers

    private func mapToCloth(_ item: ClothListItem) -> Cloth {
        Cloth(
            id: Int(item.clothId),
            imageUrl: item.imageUrl,
            name: item.name,
            brand: item.brand,
            purchaseUrl: nil,
            mainCategory: item.parentCategory,
            subCategory: item.category,
            seasons: []
        )
    }

    func fetchClothDetail(clothId: Int) async throws -> ClothDetailResult {
        return try await apiService.fetchClothDetails(clothId: Int64(clothId))
    }

    func updateCloth(clothId: Int, request: ClothUpdateAPIRequest) async throws {
        try await apiService.updateCloth(clothId: Int64(clothId), request: request)
    }

    func deleteCloth(clothId: Int) async throws {
        try await apiService.deleteCloth(clothId: Int64(clothId))
    }
    
    /// 룩북 전체 리스트 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO {
        return try await apiService.fetchLookBookList(
            lastLookBookId: lastLookBookId,
            size: size,
            direction: direction
        )
    }
}

// MARK: - ClothDataSourceError

enum ClothDataSourceError: LocalizedError {
    case inputImageCountMismatch
    
    var errorDescription: String? {
        switch self {
        case .inputImageCountMismatch:
            return "입력 데이터와 이미지 개수가 일치하지 않습니다."
        }
    }
}
