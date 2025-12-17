//
//  LookBookRepository.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

protocol LookBookRepository {
    func fetchLookBookList() async throws -> [LookBookEntity]
    func fetchProductList() async throws -> [ProductItem]
    func deleteLookBooks(ids: [Int]) async throws
    func fetchCodis(forLookbookId id: Int) async throws -> [LookBookEntity]
    func toggleLike(codyId: Int, isLiked: Bool) async throws
    func fetchBeforeCodi() async throws -> [BeforeCodiEntity]
}
