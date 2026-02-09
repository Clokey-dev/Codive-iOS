//
//  TodayCodiUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

import Foundation

final class TodayCodiUseCase {
    
    private let repository: HomeRepository
    
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    /// 오늘의 코디 생성
    func createTodayCoordinate(
        request: CreateTodayCoordinateRequestDTO
    ) async throws -> TodayCoordinateEntity {
        try await repository.createTodayCoordinate(request: request)
    }
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinatePreview() async throws -> FetchTodayCoordinatePreviewResponseDTO {
        return try await repository.fetchTodayCoordinatePreview()
    }
    
    func fetchTodayCoordinateDetails() async throws -> [FetchTodayCoordinateDetailsResponseDTO] {
        return try await repository.fetchTodayCoordinateDetails()
    }
    
    func execute(jpgData: Data) async throws -> String {
        guard !jpgData.isEmpty else {
            throw HomeAPIError.invalidResponse
        }
        
        let uploadedURL = try await repository.uploadCodiImage(jpgData: jpgData)
        
        return uploadedURL
    }
    
    /// 오늘의 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws {
        try await repository.patchUpdateCoordinates(coordinateId: coordinateId, request: request)
    }
}
