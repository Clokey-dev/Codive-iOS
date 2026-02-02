//
//  LookBookRepository.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import CodiveAPI
import Foundation

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
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload
    ) async throws -> (content: [SpecificLookBookCodiEntity], isLast: Bool)
    
    /// 과거 일일 코디 조회
    func fetchPastCoordinates(
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.Coordinate_getDailyCoordinates.Input.Query.directionPayload
    ) async throws -> (content: [BeforeCoordinateDailyEntity], isLast: Bool)
    
    /// 코디 preview 조회
    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewEntity
    
    /// 코디 detail 조회
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailEntity]
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinateClothes() async throws -> [TodayCoordinateClothEntity]
    
    /// 옷 리스트 조회
    func fetchClothItems(category: String?) async throws -> [ProductItem]
    
    /// 룩북 생성
    func createLookBook(request: CreateLookBookAPIRequestDTO) async throws -> CreateLookBookResponseDTO
    
    /// 코디 수동 생성
    func createManualCoordinate(request: CreateManualCoordinateAPIRequestDTO) async throws -> ManualCoordinateEntity
    
    /// 룩북 삭제
    func deleteLookBook(lookBookId: Int64) async throws
    
    /// 룩북 수정
    func updateLookBook(lookBookId: Int64, request: UpdateLookBookAPIRequestDTO) async throws
    
    /// 코디 삭제
    func deleteCoordinate(coordinateId: Int64) async throws
    
    /// 코디 좋아요 토글
    func patchCoordinateLike(coordinateId: Int64) async throws
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws
    
    /// 이전 일일 코디로 자동 생성
    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> AutoDailyCoordinateEntity
    
    /// 하단은 삭제해야할 기존 코드
    
//    // 과거 일일 코디 조회
//    func fetchBeforeCoordinateDaily() async throws -> [BeforeCoordinateDailyEntity]
//    
//    // 코디 좋아요
//    func toggleCodiLike(_ request: CodiLikeEntity, isLiked: Bool) async throws
//    // 코디 삭제
//    func deleteCodis(_ codis: [DeleteCodiEntity], lookbookId: Int) async throws
//    
//    // 코디 프리뷰 조회
//    func fetchCoordinatePreview(coordinateId: Int) async throws -> CoordinatePreviewEntity
    
    func uploadCodiImage(jpgData: Data) async throws -> String
}
