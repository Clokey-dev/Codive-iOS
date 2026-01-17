//
//  ClothDataSource.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation

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
}

// MARK: - DefaultClothDataSource

final class DefaultClothDataSource: ClothDataSource {

    // MARK: - Properties
    
    private let apiService: ClothAPIServiceProtocol
    
    // MARK: - Initializer
    
    init(apiService: ClothAPIServiceProtocol = ClothAPIService()) {
        self.apiService = apiService
    }

    // MARK: - Mock Data (TODO: API 연결 후 제거)

    private let mockClothItems: [ProductItem] = [
        ProductItem(id: 1, imageName: "sample1", isTodayCloth: true, brand: "Nike", name: "에어포스 1"),
        ProductItem(id: 2, imageName: "sample2", isTodayCloth: true, brand: "Adidas", name: "후디"),
        ProductItem(id: 3, imageName: "sample3", isTodayCloth: true, brand: nil, name: "검은 모자"),
        ProductItem(id: 4, imageName: "sample4", isTodayCloth: false, brand: "Uniqlo", name: "오버핏 티셔츠"),
        ProductItem(id: 5, imageName: "sample5", isTodayCloth: false, brand: "Zara", name: "슬랙스"),
        ProductItem(id: 6, imageName: "sample6", isTodayCloth: false, brand: nil, name: nil)
    ]

    // MARK: - Methods
    
    func fetchClothItems(category: String?) async throws -> [ProductItem] {
        // TODO: 실제 API 호출로 대체

        // 카테고리 필터링 (전체면 전부 반환)
        if let category = category, category != "전체" {
            return mockClothItems.filter { _ in
                // TODO: ProductItem에 category 필드 추가 후 필터링
                return true
            }
        }

        return mockClothItems
    }

    /// 옷 저장 (전체 흐름: Presigned URL → S3 업로드 → 옷 생성)
    func saveClothes(inputs: [ClothInput], images: [Data]) async throws -> [Cloth] {
        guard inputs.count == images.count else {
            throw ClothDataSourceError.inputImageCountMismatch
        }

        // Step 1: Presigned URL 발급
        let presignedInfos = try await apiService.getPresignedUrls(for: images)

        // Step 2: S3에 이미지 업로드
        for (imageData, presignedInfo) in zip(images, presignedInfos) {
            try await apiService.uploadImageToS3(
                presignedUrl: presignedInfo.presignedUrl,
                imageData: imageData,
                contentMD5: presignedInfo.md5Hash
            )
        }

        // Step 3: 옷 생성 API 호출
        let createRequests = zip(inputs, presignedInfos).map { input, presignedInfo in
            ClothCreateAPIRequest(
                clothImageUrl: presignedInfo.finalUrl,
                clothUrl: input.purchaseUrl.isEmpty ? nil : input.purchaseUrl,
                name: input.name.isEmpty ? nil : input.name,
                brand: input.brand.isEmpty ? nil : input.brand,
                season: input.seasons.first ?? .spring,
                categoryId: Int64(input.categoryId ?? 0)
            )
        }

        let clothIds = try await apiService.createClothes(requests: createRequests)
        
        // 결과 변환: clothIds + inputs → Cloth 엔티티
        return zip(clothIds, zip(inputs, presignedInfos)).map { clothId, pair in
            let (input, presignedInfo) = pair
            return Cloth(
                id: Int(clothId),
                imageUrl: presignedInfo.finalUrl,
                name: input.name.isEmpty ? nil : input.name,
                brand: input.brand.isEmpty ? nil : input.brand,
                purchaseUrl: input.purchaseUrl.isEmpty ? nil : input.purchaseUrl,
                categoryId: input.categoryId,
                seasons: input.seasons
            )
        }
    }

    func fetchMyClosetClothItems(
        categoryId: Int?,
        seasons: Set<Season>,
        searchText: String?
    ) async throws -> [Cloth] {
        let result = try await apiService.fetchClothes(
            lastClothId: nil,
            size: 100,
            categoryId: categoryId.map { Int64($0) },
            seasons: Array(seasons)
        )

        var clothes = result.clothes.map(mapToCloth)

        if let searchText = searchText, !searchText.isEmpty {
            clothes = clothes.filter { cloth in
                let nameMatch = cloth.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let brandMatch = cloth.brand?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatch || brandMatch
            }
        }

        return clothes
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
            brand: item.brand
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
