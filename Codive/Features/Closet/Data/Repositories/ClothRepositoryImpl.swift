//
//  ClothRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation
import CodiveAPI

// MARK: - ClothRepositoryImpl

final class ClothRepositoryImpl: ClothRepository {

    // MARK: - Properties
    
    private let dataSource: ClothDataSource

    // MARK: - Initializer
    
    init(dataSource: ClothDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Methods
    
    func fetchClothItems(category: String?) async throws -> [ProductItem] {
        return try await dataSource.fetchClothItems(category: category)
    }

    func saveClothes(_ inputs: [ClothInput], images: [Data]) async throws -> [Cloth] {
        // DataSource를 통해 전체 흐름 실행:
        // 1. Presigned URL 발급
        // 2. S3 업로드
        // 3. 옷 생성 API 호출
        return try await dataSource.saveClothes(inputs: inputs, images: images)
    }

    func fetchMyClosetClothItems(
        mainCategory: String?,
        subCategory: String?,
        seasons: Set<Season>,
        searchText: String?
    ) async throws -> [Cloth] {
        // 카테고리 ID 변환 (Repository 레이어에서 처리)
        var categoryId: Int?
        if let subCategory = subCategory {
            // 하위 카테고리 선택 시 → 하위 카테고리 ID
            for category in CategoryConstants.all {
                if let sub = category.subcategories.first(where: { $0.name == subCategory }) {
                    categoryId = sub.id
                    break
                }
            }
        } else if let mainCategory = mainCategory, mainCategory != "전체" {
            // 대분류만 선택 시 → 대분류 카테고리 ID
            categoryId = CategoryConstants.category(byName: mainCategory)?.id
        }

        return try await dataSource.fetchMyClosetClothItems(
            categoryId: categoryId,
            seasons: seasons,
            searchText: searchText
        )
    }

    func deleteClothItems(_ clothIds: [Int]) async throws {
        try await dataSource.deleteClothItems(clothIds)
    }
    
    // MARK: - API 연동 메서드
    
    func fetchClothList(
        lastClothId: Int?,
        size: Int,
        categoryId: Int?,
        seasons: Set<Season>
    ) async throws -> (clothes: [Cloth], isLast: Bool) {
        return try await dataSource.fetchClothList(
            lastClothId: lastClothId,
            size: size,
            categoryId: categoryId,
            seasons: seasons
        )
    }
    
    func fetchClothDetail(clothId: Int) async throws -> ClothDetailResult {
        return try await dataSource.fetchClothDetail(clothId: clothId)
    }
    
    func updateCloth(clothId: Int, request: ClothUpdateAPIRequest) async throws {
        try await dataSource.updateCloth(clothId: clothId, request: request)
    }
    
    func deleteCloth(clothId: Int) async throws {
        try await dataSource.deleteCloth(clothId: clothId)
    }
    
    // 룩북 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> (content: [LookBookEntity], isLast: Bool) {
        let dto = try await dataSource.fetchLookBookList(
            lastLookBookId: lastLookBookId,
            size: size,
            direction: direction
        )
        
        return (
            content: dto.content.map { $0.toEntity() },
            isLast: dto.isLast
        )
    }
}
