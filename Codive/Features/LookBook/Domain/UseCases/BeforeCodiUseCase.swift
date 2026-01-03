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

    /// 이전에 저장된 코디 목록 조회
    func fetchBeforeCodiList() async throws -> [BeforeCodiEntity] {
        try await repository.fetchBeforeCodi()
    }
}
