//
//  CodiUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

import CodiveAPI

final class CodiUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }
    
    /// 코디 preview 조회
    func fetchCoordinatePreview(
        coordinateId: Int64
    ) async throws -> CoordinatePreviewEntity {
        try await repository.fetchCoordinatePreview(coordinateId: coordinateId)
    }
    
    /// 코디 detail 조회
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailEntity] {
        try await repository.fetchCoordinateDetail(coordinateId: coordinateId)
    }
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinateClothes() async throws -> [TodayCoordinateClothEntity] {
        try await repository.fetchTodayCoordinateClothes()
    }
    
    /// 코디 수동 생성
    func createManualCoordinate(
        request: CreateManualCoordinateAPIRequestDTO
    ) async throws -> ManualCoordinateEntity {
        try await repository.createManualCoordinate(request: request)
    }
    
    /// 코디 좋아요 토글
    func toggleCoordinateLike(
        coordinateId: Int64
    ) async throws {
        try await repository.patchCoordinateLike(coordinateId: coordinateId)
    }
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws {
        try await repository.patchUpdateCoordinates(coordinateId: coordinateId, request: request)
    }
    
    /// 이전 일일 코디로 자동 생성
    func createAutoDailyCoordinate(
        request: CreateAutoDailyCoordinateAPIRequestDTO
    ) async throws -> AutoDailyCoordinateEntity {
        try await repository.createAutoDailyCoordinate(request: request)
    }
}

extension CodiUseCase {
    func fetchCoordinatePreview(coordinateId: Int) async throws -> CoordinatePreviewEntity {
        try await repository.fetchCoordinatePreview(coordinateId: coordinateId)
    }
}
