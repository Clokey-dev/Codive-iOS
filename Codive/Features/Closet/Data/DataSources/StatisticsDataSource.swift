//
//  StatisticsDataSource.swift
//  Codive
//
//  Created by 황상환 on 2/26/26.
//

import Foundation

// MARK: - StatisticsDataSource Protocol

protocol StatisticsDataSource {
    func checkStatisticsCondition() async throws -> Bool
    func getFavoriteItems() async throws -> [FavoriteItemPayload]
    func getFavoriteCategoryItems(categoryId: Int64) async throws -> [FavoriteCategoryItemPayload]
    func getClosetUtilization(season: String) async throws -> ClosetUtilizationPayload
}

// MARK: - DefaultStatisticsDataSource

final class DefaultStatisticsDataSource: StatisticsDataSource {

    // MARK: - Properties
    private let apiService: StatisticsAPIServiceProtocol

    // MARK: - Initializer
    init(apiService: StatisticsAPIServiceProtocol) {
        self.apiService = apiService
    }

    // MARK: - Methods
    func checkStatisticsCondition() async throws -> Bool {
        return try await apiService.checkStatisticsCondition()
    }

    func getFavoriteItems() async throws -> [FavoriteItemPayload] {
        return try await apiService.getFavoriteItems()
    }

    func getFavoriteCategoryItems(categoryId: Int64) async throws -> [FavoriteCategoryItemPayload] {
        return try await apiService.getFavoriteCategoryItems(categoryId: categoryId)
    }

    func getClosetUtilization(season: String) async throws -> ClosetUtilizationPayload {
        return try await apiService.getClosetUtilization(season: season)
    }
}
