//
//  StatisticsRepository.swift
//  Codive
//
//  Created by 황상환 on 2/26/26.
//

import Foundation

// MARK: - StatisticsRepository

protocol StatisticsRepository {
    func checkStatisticsCondition() async throws -> Bool
    func getFavoriteItems() async throws -> [FavoriteItemPayload]
    func getFavoriteCategoryItems(categoryId: Int64) async throws -> [FavoriteCategoryItemPayload]
    func getClosetUtilization(season: String) async throws -> ClosetUtilizationPayload
}
