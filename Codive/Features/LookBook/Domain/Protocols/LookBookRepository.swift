//
//  LookBookRepository.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

protocol LookBookRepository {
    // 룩북 조회
    func fetchLookBookList() async throws -> [LookBookEntity]
    // 특정 룩북의 코디 목록 조회
    func fetchCodisForLookBook(forLookbookId id: Int) async throws -> [SpecificLookBookCodiEntity]
    // 과거 일일 코디 조회
    func fetchBeforeCoordinateDaily() async throws -> [BeforeCoordinateDailyEntity]
    // 룩북 생성
    func createLookBook(title: String) async throws -> CreateLookBookEntity
    func fetchProductList() async throws -> [ProductItem]
    func deleteLookBooks(ids: [Int]) async throws
    func fetchCodiDetail(codiId: Int) async throws -> CodiDetailEntity?
    func toggleLike(codyId: Int, isLiked: Bool) async throws
}
