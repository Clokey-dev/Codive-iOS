//
//  FetchMyFavoriteLookBookUseCase.swift
//  Codive
//
//  Created by 한금준 on 2/5/26.
//

final class FetchMyFavoriteLookBookUseCase {
    // MARK: - Properties
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }
    
    func fetchMyFavoriteCoordinate() async throws -> [MyFavoriteLookBookResponseDTO] {
        try await repository.fetchMyFavoriteCoordinate()
    }
}
