//
//  BeforeCodiUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

final class BeforeCodiUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }

    // MARK: - Before Codi

    /// 과거 일일 코디 목록 조회
    func fetchBeforeCoordinateDailyList() async throws -> [BeforeCoordinateDailyEntity] {
        try await repository.fetchBeforeCoordinateDaily()
    }
}
