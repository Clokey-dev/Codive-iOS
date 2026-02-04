//
//  LookBookAPIServiceProtocol.swift
//  Codive
//
//  Created by 한금준 on 2/1/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

protocol LookBookAPIServiceProtocol {
    /// 룩북 전체 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO
    
    /// 개별 룩북 내 코디 조회
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload
    ) async throws -> LookBookCoordinateResponseDTO
    
    /// 과거 일일 코디 조회
    func fetchPastCoordinates(
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.Coordinate_getDailyCoordinates.Input.Query.directionPayload
    ) async throws -> PastDailyCoordinateResponseDTO
    
    /// 코디 preview 조회
    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewResponseDTO
    
    /// 코디 detail 조회
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailResponseDTO]
    
    /// 옷 리스트 조회
    func fetchClothes(lastClothId: Int64?, size: Int32, categoryId: Int64?, seasons: [Season]) async throws -> ClothListResult
    
    /// 룩북 생성
    func createLookBook(request: CreateLookBookAPIRequestDTO) async throws -> CreateLookBookResponseDTO
    
    /// 코디 수동 생성
    func createManualCoordinate(request: CreateManualCoordinateAPIRequestDTO) async throws -> CreateManualCoordinateAPIResponseDTO
    
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
    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> CreateAutoDailyCoordinateAPIResponseDTO
    
    /// 이미지 url 생성
    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo]
}
