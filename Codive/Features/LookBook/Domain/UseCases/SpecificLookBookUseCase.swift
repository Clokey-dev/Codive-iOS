//
//  SpecificLookBookUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

import CodiveAPI

final class SpecificLookBookUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }

    // MARK: - LookBook Detail (Codi List)

    /// 특정 룩북에 포함된 코디 목록 조회
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload
    ) async throws -> (content: [SpecificLookBookCodiEntity], isLast: Bool) {
        return try await repository.fetchLookBookCoordinateList(
            lookBookId: lookBookId,
            lastLookBookId: lastLookBookId,
            size: size,
            direction: direction
        )
    }
    
    /// 코디 좋아요 상태 변경
    func toggleLike(coordinateId: Int, isLiked: Bool) async throws {
        let request = CodiLikeEntity(coordinateId: coordinateId)
        try await repository.toggleCodiLike(request, isLiked: isLiked)
    }
    
    /// 코디 삭제
    func deleteCodis(ids: [Int], lookbookId: Int) async throws {
        let requests = ids.map {
            DeleteCodiEntity(coordinateId: $0)
        }
        try await repository.deleteCodis(
            requests,
            lookbookId: lookbookId
        )
    }
    
    /// 룩북 이름 수정
    func editLookBookName(lookBookId: Int, newName: String) async throws {
        let entity = EditLookBookEntity(
            lookBookId: lookBookId,
            name: newName
        )
        
        try await repository.editLookBook(entity)
    }
}
