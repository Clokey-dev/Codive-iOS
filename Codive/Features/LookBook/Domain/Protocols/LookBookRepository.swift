//
//  LookBookRepository.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import CodiveAPI

protocol LookBookRepository {
    // 룩북 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> (content: [LookBookEntity], isLast: Bool)
    // 특정 룩북의 코디 목록 조회
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload
    ) async throws -> (content: [SpecificLookBookCodiEntity], isLast: Bool)
    // 과거 일일 코디 조회
    func fetchBeforeCoordinateDaily() async throws -> [BeforeCoordinateDailyEntity]
    // 룩북 생성
    func createLookBook(request: CreateLookBookAPIRequestDTO) async throws -> CreateLookBookResponseDTO
    // 룩북 삭제
    func deleteLookBook(lookBookId: Int64) async throws
    // 코디 좋아요
    func toggleCodiLike(_ request: CodiLikeEntity, isLiked: Bool) async throws
    // 코디 삭제
    func deleteCodis(_ codis: [DeleteCodiEntity], lookbookId: Int) async throws
    // 룩북 이름 수정
    func updateLookBook(lookBookId: Int64, request: UpdateLookBookAPIRequestDTO) async throws
    // 코디 프리뷰 조회
    func fetchCoordinatePreview(coordinateId: Int) async throws -> CoordinatePreviewEntity
    func fetchProductList() async throws -> [ProductItem]
}
