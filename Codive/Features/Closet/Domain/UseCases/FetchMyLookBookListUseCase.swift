//
//  FetchMyLookBookListUseCase.swift
//  Codive
//
//  Created by 한금준 on 2/4/26.
//

import CodiveAPI

// MARK: - FetchMyLookBookListUseCase
final class FetchMyLookBookListUseCase {

    // MARK: - Properties
    private let repository: ClothRepository

    // MARK: - Initializer
    init(repository: ClothRepository) {
        self.repository = repository
    }

    // MARK: - Methods
    /// 룩북 목록 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> (content: [LookBookEntity], isLast: Bool) {
        return try await repository.fetchLookBookList(
            lastLookBookId: lastLookBookId,
            size: size,
            direction: direction
        )
    }
}
