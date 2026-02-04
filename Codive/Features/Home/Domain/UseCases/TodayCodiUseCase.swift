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
    func fetchTodayCoordinateClothes() async throws -> [TodayCoordinateClothEntity] {
        try await repository.fetchTodayCoordinateClothes()
    }
    
    func execute(jpgData: Data) async throws -> String {
        guard !jpgData.isEmpty else {
            throw HomeAPIError.invalidResponse
        }
        
        let uploadedURL = try await repository.uploadCodiImage(jpgData: jpgData)
        
        return uploadedURL
    }
}
