//
//  LookBookDetailUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

final class LookBookDetailUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }

    // MARK: - LookBook Detail (Codi List)

    /// 특정 룩북에 포함된 코디 목록 조회
    func fetchCodisForLookBook(forLookbookId id: Int) async throws -> [SpecificLookBookCodiEntity] {
        try await repository.fetchCodisForLookBook(forLookbookId: id)
    }
}
