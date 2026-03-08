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
}
