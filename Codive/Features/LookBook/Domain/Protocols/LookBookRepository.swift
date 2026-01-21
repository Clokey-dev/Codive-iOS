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
    // 룩북 삭제
    func deleteLookBooks(_ lookBooks: [DeleteLookBookEntity]) async throws
    // 코디 좋아요
    func toggleCodiLike(_ request: CodiLikeEntity, isLiked: Bool) async throws
    // 코디 삭제
    func deleteCodis(_ codis: [DeleteCodiEntity], lookbookId: Int) async throws
    // 룩북 이름 수정
    func editLookBook(_ entity: EditLookBookEntity) async throws
    // 코디 프리뷰 조회
    func fetchCoordinatePreview(coordinateId: Int) async throws -> CoordinatePreviewEntity
    func fetchProductList() async throws -> [ProductItem]
}
