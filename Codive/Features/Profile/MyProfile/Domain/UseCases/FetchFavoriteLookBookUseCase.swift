//
//  FetchMyFavoriteLookBookUseCase.swift
//  Codive
//
//  Created by 한금준 on 2/5/26.
//

final class FetchFavoriteLookBookUseCase {
    // MARK: - Properties
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }
    
    func fetchFavoriteCoordinate(memberId: String?) async throws -> [MyFavoriteLookBookResponseDTO] {
        try await repository.fetchMyFavoriteCoordinate(memberId: memberId)
    }

    func fetchFavoriteCoordinate(memberId: Int) async throws -> [MyFavoriteLookBookResponseDTO] {
        try await repository.fetchFavoriteCoordinate(memberId: memberId)
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
}
