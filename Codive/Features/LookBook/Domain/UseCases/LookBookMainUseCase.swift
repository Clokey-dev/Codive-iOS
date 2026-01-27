//
//  LookBookMainUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

import CodiveAPI

final class LookBookMainUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }

    // MARK: - LookBook List

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
    
    /// 룩북 생성
    func createLookBook(request: CreateLookBookAPIRequestDTO) async throws -> CreateLookBookResponseDTO {
        return try await repository.createLookBook(request: request)
    }

    /// 룩북 삭제
    func deleteLookBook(lookBookId: Int64) async throws {
        try await repository.deleteLookBook(lookBookId: lookBookId)
    }
}
