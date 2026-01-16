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

    func fetchCodisForLookBook(forLookbookId id: Int) async throws -> [SpecificLookBookCodiEntity] {
        return try await datasource.fetchCodisForLookBook(id: id)
    }

    func fetchBeforeCoordinateDaily() async throws -> [BeforeCoordinateDailyEntity] {
        return try await datasource.fetchBeforeCoordinateDaily()
    }
    
    func createLookBook(title: String) async throws -> CreateLookBookEntity {
        try await datasource.createLookBook(title: title)
    }
    
    func deleteLookBooks(_ lookBooks: [DeleteLookBookEntity]) async throws {
        try await datasource.deleteLookBooks(lookBooks)
    }

    func toggleCodiLike(_ request: CodiLikeEntity, isLiked: Bool) async throws {
        try await datasource.toggleCodiLike(request, isLiked: isLiked)
    }
    
    func deleteCodis(_ codis: [DeleteCodiEntity], lookbookId: Int) async throws {
        try await datasource.deleteCodis(codis, lookbookId: lookbookId)
    }

    // MARK: - Codi Detail
    
    /// 코디 상세 정보 조회
    /// - Parameter codiId: 코디 ID
    /// - Returns: 코디 상세 엔티티 (없을 경우 nil)
    func fetchCodiDetail(codiId: Int) async throws -> CodiDetailEntity? {
        return try await datasource.fetchCodiDetail(codiId: codiId)
    }
    
    // MARK: - Product
    
    /// 코디 구성에 사용되는 상품 목록 조회
    func fetchProductList() async throws -> [ProductItem] {
        return try await datasource.fetchProductList()
    }
}
