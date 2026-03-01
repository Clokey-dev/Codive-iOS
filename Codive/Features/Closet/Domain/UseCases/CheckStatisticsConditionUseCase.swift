//
//  CheckStatisticsConditionUseCase.swift
//  Codive
//
//  Created by claude on 2/26/26.
//

import Foundation

// MARK: - CheckStatisticsConditionUseCase

final class CheckStatisticsConditionUseCase {

    // MARK: - Properties
    private let repository: StatisticsRepository

    // MARK: - Initializer
    init(repository: StatisticsRepository) {
        self.repository = repository
    }

    // MARK: - Methods
    func execute() async throws -> Bool {
        return try await repository.checkStatisticsCondition()
    }
}
