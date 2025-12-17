//
//  LookBookRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

final class LookBookRepositoryImpl: LookBookRepository {
    // MARK: - Properties
    private let datasource: LookBookDataSource
    
    // MARK: - Initializer
    init(datasource: LookBookDataSource) {
        self.datasource = datasource
    }
    
    func fetchLookBookList() async throws -> [LookBookEntity] {
        return try await datasource.fetchLookBookList()
    }
    
    func deleteLookBooks(ids: [Int]) async throws {
        try await datasource.deleteLookBooks(ids: ids)
    }
    
    func fetchCodis(forLookbookId id: Int) async throws -> [LookBookEntity] {
        return try await datasource.fetchCodisForLookBook(id: id)
    }
    
    func toggleLike(codyId: Int, isLiked: Bool) async throws {
        try await datasource.toggleLike(codyId: codyId, isLiked: isLiked)
    }
    
    func fetchProductList() async throws -> [ProductItem] {
        return try await datasource.fetchProductList()
    }
    
    func fetchBeforeCodi() async throws -> [BeforeCodiEntity] {
        return try await datasource.fetchBeforeCodiList()
    }
}
