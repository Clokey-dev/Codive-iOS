//
//  FetchFavoriteCategoryItemsUseCase.swift
//  Codive
//
//  Created by 황상환 on 5/3/26.
//

import Foundation

final class FetchFavoriteCategoryItemsUseCase {

    private let repository: StatisticsRepository

    init(repository: StatisticsRepository) {
        self.repository = repository
    }

    func execute(categoryId: Int64) async throws -> [FavoriteCategoryItemPayload] {
        return try await repository.getFavoriteCategoryItems(categoryId: categoryId)
    }
}
