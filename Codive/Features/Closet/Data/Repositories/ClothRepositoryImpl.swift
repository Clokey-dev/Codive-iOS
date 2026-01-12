//
//  ClothRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation

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
        return try await dataSource.fetchMyClosetClothItems(
            mainCategory: mainCategory,
            subCategory: subCategory,
            seasons: seasons,
            searchText: searchText
        )
    }

    func deleteClothItems(_ clothIds: [Int]) async throws {
        try await dataSource.deleteClothItems(clothIds)
    }
}
