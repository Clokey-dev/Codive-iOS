//
//  StatisticsDataSource.swift
//  Codive
//
//  Created by claude on 2/26/26.
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
