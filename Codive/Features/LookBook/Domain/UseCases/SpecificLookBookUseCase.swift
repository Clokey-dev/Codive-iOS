//
//  SpecificLookBookUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

final class SpecificLookBookUseCase {

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
