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
        mainCategory: String?,
        subCategory: String?,
        seasons: Set<Season>,
        searchText: String?
    ) async throws -> [Cloth]

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

    // MARK: - Mock Data
    
    private let mockClothItems: [ProductItem] = [
        ProductItem(id: 1, imageName: "sample1", isTodayCloth: true, brand: "Nike", name: "에어포스 1"),
        ProductItem(id: 2, imageName: "sample2", isTodayCloth: true, brand: "Adidas", name: "후디"),
        ProductItem(id: 3, imageName: "sample3", isTodayCloth: true, brand: nil, name: "검은 모자"),
        ProductItem(id: 4, imageName: "sample4", isTodayCloth: false, brand: "Uniqlo", name: "오버핏 티셔츠"),
        ProductItem(id: 5, imageName: "sample5", isTodayCloth: false, brand: "Zara", name: "슬랙스"),
        ProductItem(id: 6, imageName: "sample6", isTodayCloth: false, brand: nil, name: nil)
    ]

    // MyCloset용 Mock Cloth 데이터
    private let mockMyClosetClothItems: [Cloth] = [
        // 상의
        Cloth(id: 1, imageUrl: "sample_tshirt1", name: "오버핏 반팔티", brand: "Uniqlo", categoryId: 1, seasons: [.spring, .summer]),
        Cloth(id: 2, imageUrl: "sample_knit1", name: "케이블 니트", brand: "Zara", categoryId: 1, seasons: [.fall, .winter]),
        Cloth(id: 3, imageUrl: "sample_hoodie1", name: "후드티", brand: "Nike", categoryId: 1, seasons: [.spring, .fall]),
        // 바지
        Cloth(id: 4, imageUrl: "sample_jeans1", name: "블루 청바지", brand: "Levi's", categoryId: 2, seasons: [.spring, .summer, .fall]),
        Cloth(id: 5, imageUrl: "sample_slacks1", name: "슬랙스", brand: "Zara", categoryId: 2, seasons: [.spring, .summer, .fall, .winter]),
        Cloth(id: 6, imageUrl: "sample_shorts1", name: "반바지", brand: nil, categoryId: 2, seasons: [.summer]),
        // 치마
        Cloth(id: 7, imageUrl: "sample_skirt1", name: "미니스커트", brand: "H&M", categoryId: 3, seasons: [.spring, .summer]),
        Cloth(id: 8, imageUrl: "sample_dress1", name: "원피스", brand: "Mango", categoryId: 3, seasons: [.summer]),
        // 아우터
        Cloth(id: 9, imageUrl: "sample_padding1", name: "숏패딩", brand: "The North Face", categoryId: 4, seasons: [.winter]),
        Cloth(id: 10, imageUrl: "sample_coat1", name: "울 코트", brand: "Zara", categoryId: 4, seasons: [.fall, .winter]),
        Cloth(id: 11, imageUrl: "sample_cardigan1", name: "가디건", brand: "Uniqlo", categoryId: 4, seasons: [.spring, .fall]),
        // 신발
        Cloth(id: 12, imageUrl: "sample_sneakers1", name: "에어포스 1", brand: "Nike", categoryId: 5, seasons: [.spring, .summer, .fall]),
        Cloth(id: 13, imageUrl: "sample_boots1", name: "첼시부츠", brand: "Dr.Martens", categoryId: 5, seasons: [.fall, .winter]),
        // 가방
        Cloth(id: 14, imageUrl: "sample_backpack1", name: "백팩", brand: "Eastpak", categoryId: 6, seasons: [.spring, .summer, .fall, .winter]),
        Cloth(id: 15, imageUrl: "sample_totebag1", name: "토트백", brand: nil, categoryId: 6, seasons: [.spring, .summer]),
        // 패션소품
        Cloth(id: 16, imageUrl: "sample_cap1", name: "볼캡", brand: "New Era", categoryId: 7, seasons: [.spring, .summer]),
        Cloth(id: 17, imageUrl: "sample_muffler1", name: "머플러", brand: nil, categoryId: 7, seasons: [.fall, .winter])
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
        print("📤 [ClothDataSource] Step 1: Presigned URL 발급 요청...")
        let presignedInfos = try await apiService.getPresignedUrls(for: images)
        print("✅ [ClothDataSource] Presigned URL \(presignedInfos.count)개 발급 완료")
        
        // Step 2: S3에 이미지 업로드
        print("📤 [ClothDataSource] Step 2: S3 업로드 시작...")
        for (index, (imageData, presignedInfo)) in zip(images, presignedInfos).enumerated() {
            print("   - 이미지 \(index + 1)/\(images.count) 업로드 중...")
            try await apiService.uploadImageToS3(
                presignedUrl: presignedInfo.presignedUrl,
                imageData: imageData,
                contentMD5: presignedInfo.md5Hash
            )
        }
        print("✅ [ClothDataSource] S3 업로드 완료")
        
        // Step 3: 옷 생성 API 호출
        print("📤 [ClothDataSource] Step 3: 옷 생성 API 호출...")
        let createRequests = zip(inputs, presignedInfos).map { input, presignedInfo in
            ClothCreateAPIRequest(
                clothImageUrl: presignedInfo.finalUrl,
                clothUrl: input.purchaseUrl.isEmpty ? nil : input.purchaseUrl,
                name: input.name.isEmpty ? nil : input.name,
                brand: input.brand.isEmpty ? nil : input.brand,
                season: input.seasons.first ?? .spring,  // 첫 번째 계절 사용
                categoryId: Int64(input.categoryId ?? 0)
            )
        }
        
        let clothIds = try await apiService.createClothes(requests: createRequests)
        print("✅ [ClothDataSource] 옷 생성 완료: \(clothIds)")
        
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
        mainCategory: String?,
        subCategory: String?,
        seasons: Set<Season>,
        searchText: String?
    ) async throws -> [Cloth] {
        // TODO: 실제 API 호출로 대체

        var filteredItems = mockMyClosetClothItems

        // 1. 메인 카테고리 필터링
        if let mainCategory = mainCategory, mainCategory != "전체" {
            if let category = CategoryConstants.category(byName: mainCategory) {
                filteredItems = filteredItems.filter { $0.categoryId == category.id }
            }
        }

        // 2. 서브 카테고리 필터링
        // TODO: Cloth에 subCategoryId 추가되면 구현

        // 3. 계절 필터링
        if !seasons.isEmpty {
            filteredItems = filteredItems.filter { cloth in
                !cloth.seasons.isDisjoint(with: seasons)
            }
        }

        // 4. 검색어 필터링
        if let searchText = searchText, !searchText.isEmpty {
            filteredItems = filteredItems.filter { cloth in
                let nameMatch = cloth.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let brandMatch = cloth.brand?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatch || brandMatch
            }
        }

        return filteredItems
    }

    func deleteClothItems(_ clothIds: [Int]) async throws {
        // TODO: 실제 API 호출로 대체
        // Mock 환경: 성공만 반환
        print("Mock: \(clothIds) 삭제 성공")
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
