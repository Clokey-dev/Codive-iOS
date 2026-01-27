//
//  BeforeCodiUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

import CodiveAPI

final class BeforeCodiUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }

    // MARK: - Before Codi

    /// 과거 일일 코디 조회
    func fetchPastCoordinates(
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.Coordinate_getDailyCoordinates.Input.Query.directionPayload
    ) async throws -> (content: [BeforeCoordinateDailyEntity], isLast: Bool) {
        try await repository.fetchPastCoordinates(
            lastCoordinateId: lastCoordinateId,
            size: size,
            direction: direction
        )
    }
}

extension BeforeCodiUseCase {
    func fetchBeforeCoordinateDailyList() async throws -> [BeforeCoordinateDailyEntity] {
        try await repository.fetchBeforeCoordinateDaily()
    }
}
