//
//  FetchClosetUtilizationUseCase.swift
//  Codive
//
//  Created by 황상환 on 5/3/26.
//

import Foundation

final class FetchClosetUtilizationUseCase {

    private let repository: StatisticsRepository

    init(repository: StatisticsRepository) {
        self.repository = repository
    }

    func execute(season: String) async throws -> ClosetUtilizationPayload {
        return try await repository.getClosetUtilization(season: season)
    }
}
