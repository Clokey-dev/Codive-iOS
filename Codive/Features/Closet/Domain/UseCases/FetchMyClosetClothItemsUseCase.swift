//
//  FetchMyClosetClothItemsUseCase.swift
//  Codive
//
//  Created by 황상환 on 12/21/25.
//

import Foundation

// MARK: - FetchMyClosetClothItemsUseCase
final class FetchMyClosetClothItemsUseCase {

    // MARK: - Properties
    private let repository: ClothRepository

    // MARK: - Initializer
    init(repository: ClothRepository) {
        self.repository = repository
    }

    // MARK: - Methods
    func execute(
        mainCategory: String?,
        subCategory: String?,
        seasons: Set<Season>,
        searchText: String?
    ) async throws -> [Cloth] {
        return try await repository.fetchMyClosetClothItems(
            mainCategory: mainCategory,
            subCategory: subCategory,
            seasons: seasons,
            searchText: searchText
        )
    }
}
