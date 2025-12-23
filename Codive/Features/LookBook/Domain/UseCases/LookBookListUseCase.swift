//
//  LookBookListUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

final class LookBookListUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }

    // MARK: - LookBook List

    /// 룩북 목록 조회
    func fetchLookBookList() async throws -> [LookBookEntity] {
        try await repository.fetchLookBookList()
    }

    /// 선택된 룩북 삭제
    func deleteLookBooks(ids: [Int]) async throws {
        try await repository.deleteLookBooks(ids: ids)
    }
}
