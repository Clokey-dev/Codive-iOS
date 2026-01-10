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
    
    // MARK: - LookBook List
    
    func fetchLookBookList() async throws -> [LookBookEntity] {
        return try await datasource.fetchLookBookList()
    }
    
    // MARK: - Codi List In LookBook

    func fetchCodisForLookBook(forLookbookId id: Int) async throws -> [SpecificLookBookCodiEntity] {
        return try await datasource.fetchCodisForLookBook(id: id)
    }
    
    // MARK: - Before Codi

    func fetchBeforeCoordinateDaily() async throws -> [BeforeCoordinateDailyEntity] {
        return try await datasource.fetchBeforeCoordinateDaily()
    }
    
    func createLookBook(title: String) async throws -> CreateLookBookEntity {
        try await datasource.createLookBook(title: title)
    }
    
    // ---------------
    
    /// LookBook 삭제
    /// - Parameter ids: 삭제할 룩북 ID 배열
    func deleteLookBooks(ids: [Int]) async throws {
        try await datasource.deleteLookBooks(ids: ids)
    }
    
    // MARK: - Codi Detail
    
    /// 코디 상세 정보 조회
    /// - Parameter codiId: 코디 ID
    /// - Returns: 코디 상세 엔티티 (없을 경우 nil)
    func fetchCodiDetail(codiId: Int) async throws -> CodiDetailEntity? {
        return try await datasource.fetchCodiDetail(codiId: codiId)
    }
    
    // MARK: - Codi Like
    
    /// 코디 좋아요 상태 변경
    /// - Parameters:
    ///   - codyId: 코디 ID
    ///   - isLiked: 좋아요 여부
    func toggleLike(codyId: Int, isLiked: Bool) async throws {
        try await datasource.toggleLike(codyId: codyId, isLiked: isLiked)
    }
    
    // MARK: - Product
    
    /// 코디 구성에 사용되는 상품 목록 조회
    func fetchProductList() async throws -> [ProductItem] {
        return try await datasource.fetchProductList()
    }
}
