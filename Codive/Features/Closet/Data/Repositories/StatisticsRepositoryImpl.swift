//
//  StatisticsRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 2/26/26.
//

import Foundation

// MARK: - StatisticsRepositoryImpl

final class StatisticsRepositoryImpl: StatisticsRepository {

    // MARK: - Properties
    private let dataSource: StatisticsDataSource

    // MARK: - Initializer
    init(dataSource: StatisticsDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Methods
    func checkStatisticsCondition() async throws -> Bool {
        return try await dataSource.checkStatisticsCondition()
    }
}
