//
//  LookBookUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

final class LookBookUseCase {
    // MARK: - Properties
    private let repository: LookBookRepository
    
    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }
    
    func fetchLookBookList() async throws -> [LookBookEntity] {
        return try await repository.fetchLookBookList()
    }
    
    func deleteLookBooks(ids: [Int]) async throws {
        try await repository.deleteLookBooks(ids: ids)
    }

    func fetchCodis(forLookbookId id: Int) async throws -> [LookBookEntity] {
        return try await repository.fetchCodis(forLookbookId: id)
    }

    func toggleLike(codyId: Int, isLiked: Bool) async throws {
        try await repository.toggleLike(codyId: codyId, isLiked: isLiked)
    }
    
    func fetchProductList() async throws -> [ProductItem] {
        return try await repository.fetchProductList()
    }
    
    func fetchBeforeCodiList() async throws -> [BeforeCodiEntity] {
        return try await repository.fetchBeforeCodi()
    }
}
