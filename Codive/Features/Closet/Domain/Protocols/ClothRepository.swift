//
//  ClothRepository.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation

// MARK: - ClothRepository
protocol ClothRepository {
    func fetchClothItems(category: String?) async throws -> [ProductItem]
    func saveClothes(_ inputs: [ClothInput], images: [Data]) async throws -> [Cloth]

    // MyCloset 전용 메서드
    func fetchMyClosetClothItems(
        mainCategory: String?,
        subCategory: String?,
        seasons: Set<Season>,
        searchText: String?
    ) async throws -> [Cloth]

    func deleteClothItems(_ clothIds: [Int]) async throws
}
