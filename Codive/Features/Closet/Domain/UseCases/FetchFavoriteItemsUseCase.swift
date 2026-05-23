//
//  FetchFavoriteItemsUseCase.swift
//  Codive
//
//  Created by 황상환 on 5/3/26.
//

import Foundation

final class FetchFavoriteItemsUseCase {

    private let repository: StatisticsRepository

    init(repository: StatisticsRepository) {
        self.repository = repository
    }

    func execute() async throws -> [FavoriteItemPayload] {
        return try await repository.getFavoriteItems()
    }
}
