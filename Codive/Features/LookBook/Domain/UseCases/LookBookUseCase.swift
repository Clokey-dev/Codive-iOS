//
//  LookBookUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

final class LookBookUseCase {
    
    // MARK: - Dependencies
    private let repository: LookBookRepository
    
    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }
    
    // MARK: - LookBook
    
    /// 룩북 목록 조회
    /// - Returns: 전체 룩북 엔티티 배열
    func fetchLookBookList() async throws -> [LookBookEntity] {
        return try await repository.fetchLookBookList()
    }
    
    /// 선택된 룩북 삭제
    /// - Parameter ids: 삭제할 룩북 ID 배열
    func deleteLookBooks(ids: [Int]) async throws {
        try await repository.deleteLookBooks(ids: ids)
    }
    
    // MARK: - LookBook Detail (Codi List)
    
    /// 특정 룩북에 포함된 코디 목록 조회
    /// - Parameter id: 룩북 ID
    /// - Returns: 해당 룩북에 속한 코디 리스트
    func fetchCodis(forLookbookId id: Int) async throws -> [LookBookEntity] {
        return try await repository.fetchCodis(forLookbookId: id)
    }
    
    // MARK: - Codi Detail
    
    /// 코디 상세 정보 조회
    /// - Parameter codiId: 조회할 코디 ID
    /// - Returns: 코디 상세 엔티티 (없을 경우 nil)
    func fetchCodiDetail(codiId: Int) async throws -> CodiDetailEntity? {
        return try await repository.fetchCodiDetail(codiId: codiId)
    }
    
    // MARK: - Like Action
    
    /// 코디 좋아요 상태 변경
    /// - Parameters:
    ///   - codyId: 코디 ID
    ///   - isLiked: 변경할 좋아요 상태
    func toggleLike(codyId: Int, isLiked: Bool) async throws {
        try await repository.toggleLike(codyId: codyId, isLiked: isLiked)
    }
    
    // MARK: - Product
    
    /// 코디 구성에 사용되는 상품 목록 조회
    /// AddCodiDetailView에서 사용된다.
    func fetchProductList() async throws -> [ProductItem] {
        return try await repository.fetchProductList()
    }
    
    // MARK: - Before Codi
    
    /// 이전에 저장된 코디 목록 조회
    /// AddBeforeCodiView에서 코디 불러오기 선택 시 사용된다.
    func fetchBeforeCodiList() async throws -> [BeforeCodiEntity] {
        return try await repository.fetchBeforeCodi()
    }
}
