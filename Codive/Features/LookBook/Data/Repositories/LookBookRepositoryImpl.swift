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
    
    // MARK: - LookBook Detail (Codi List)
    /// 특정 LookBook에 속한 코디 목록 조회
    /// - Parameter id: LookBook ID
    /// - Returns: 해당 룩북에 포함된 코디 목록
    func fetchCodisForLookBook(forLookbookId id: Int) async throws -> [SpecificLookBookCodiEntity] {
        return try await datasource.fetchCodisForLookBook(id: id)
    }
    
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
    
    // MARK: - Before Codi
    
    /// 이전에 저장된 코디 목록 조회
    /// 코디 추가 전 선택 화면에서 사용된다.
    func fetchBeforeCodi() async throws -> [BeforeCodiEntity] {
        return try await datasource.fetchBeforeCodiList()
    }
}
