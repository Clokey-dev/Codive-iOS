//
//  LookBookDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation
import CodiveAPI

protocol LookBookDataSourceProtocol {
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
    func fetchClothItems(category: String?) async throws -> [ProductItem]
    
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
}

final class LookBookDataSource: LookBookDataSourceProtocol {
    private let apiService: LookBookAPIServiceProtocol
    
    // MARK: - Initializer
    init(
        apiService: LookBookAPIServiceProtocol = LookBookAPIService()
    ) {
        self.apiService = apiService
    }
    
    /// 룩북 전체 리스트 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO {
        return try await apiService.fetchLookBookList(
            lastLookBookId: lastLookBookId,
            size: size,
            direction: direction
        )
    }
    
    /// 개별 룩북 전체 리스트 조회
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload
    ) async throws -> LookBookCoordinateResponseDTO {
        return try await apiService.fetchLookBookCoordinateList(
            lookBookId: lookBookId,
            lastCoordinateId: lastCoordinateId,
            size: size,
            direction: direction
        )
    }
    
    /// 과거 일일 코디 조회
    func fetchPastCoordinates(
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.Coordinate_getDailyCoordinates.Input.Query.directionPayload
    ) async throws -> PastDailyCoordinateResponseDTO {
        return try await apiService.fetchPastCoordinates(
            lastCoordinateId: lastCoordinateId,
            size: size,
            direction: direction
        )
    }
    
    /// 코디 preview 조회
    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewResponseDTO {
        return try await apiService.fetchCoordinatePreview(coordinateId: coordinateId)
    }
    
    /// 코디 detail 조회
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailResponseDTO] {
        return try await apiService.fetchCoordinateDetail(coordinateId: coordinateId)
    }
    
    /// 옷 리스트 조회
    func fetchClothItems(category: String?) async throws -> [ProductItem] {
        // 전체 옷 목록 조회 (페이지네이션 없이 전체)
        let result = try await apiService.fetchClothes(
            lastClothId: nil,
            size: 100,
            categoryId: nil,
            seasons: []
        )
        
        return result.clothes.map { item in
            ProductItem(
                id: Int(item.clothId),
                imageUrl: item.imageUrl,
                brand: item.brand,
                name: item.name
            )
        }
    }
    
    /// 룩북 생성
    func createLookBook(
        request: CreateLookBookAPIRequestDTO
    ) async throws -> CreateLookBookResponseDTO {
        return try await apiService.createLookBook(request: request)
    }
    
    /// 코디 수동 생성
    func createManualCoordinate(request: CreateManualCoordinateAPIRequestDTO) async throws -> CreateManualCoordinateAPIResponseDTO {
        return try await apiService.createManualCoordinate(request: request)
    }
    
    /// 룩북 삭제
    func deleteLookBook(lookBookId: Int64) async throws {
        try await apiService.deleteLookBook(lookBookId: lookBookId)
    }
    
    /// 룩북 수정
    func updateLookBook(lookBookId: Int64, request: UpdateLookBookAPIRequestDTO) async throws {
        try await apiService.updateLookBook(lookBookId: lookBookId, request: request)
    }
    
    /// 코디 삭제
    func deleteCoordinate(coordinateId: Int64) async throws {
        try await apiService.deleteCoordinate(coordinateId: coordinateId)
    }
    
    /// 코디 좋아요 토글
    func patchCoordinateLike(coordinateId: Int64) async throws {
        try await apiService.patchCoordinateLike(coordinateId: coordinateId)
    }
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws {
        try await apiService.patchUpdateCoordinates(coordinateId: coordinateId, request: request)
    }
    
    /// 이전 일일 코디로 자동 생성
    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> CreateAutoDailyCoordinateAPIResponseDTO {
        return try await apiService.createAutoDailyCoordinate(request: request)
    }
}

// MARK: - LookBookDataSource.swift에 추가

extension LookBookDataSource {
    /// 코디 이미지를 S3에 업로드하고 최종 URL을 반환
    func uploadCodiImage(jpgData: Data) async throws -> String {
        let presignedUrlInfos = try await apiService.getPresignedUrls(for: [jpgData])
        
        guard let urlInfo = presignedUrlInfos.first else {
            throw LookBookAPIError.uploadFailed(message: "Presigned URL 발급 실패")
        }
        
        try await uploadImageToS3(
            presignedUrl: urlInfo.presignedUrl,
            imageData: jpgData,
            md5Hash: urlInfo.md5Hash
        )

        return urlInfo.finalUrl
    }
 
    private func uploadImageToS3(
        presignedUrl: String,
        imageData: Data,
        md5Hash: String
    ) async throws {
        guard let url = URL(string: presignedUrl) else {
            throw LookBookAPIError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue(md5Hash, forHTTPHeaderField: "Content-MD5")
        request.httpBody = imageData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LookBookAPIError.uploadFailed(message: "S3 업로드 실패 (Status: \((response as? HTTPURLResponse)?.statusCode ?? -1))")
        }
        
        #if DEBUG
        print("[LookBook] S3 이미지 업로드 성공")
        #endif
    }
}
