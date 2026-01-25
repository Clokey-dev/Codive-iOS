//
//  FetchMyProfileUseCase.swift
//  Codive
//
//  Created by Claude on 1/25/26.
//

protocol FetchMyProfileUseCase {
    func execute() async throws -> MyProfileInfo
}

final class DefaultFetchMyProfileUseCase: FetchMyProfileUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute() async throws -> MyProfileInfo {
        return try await repository.fetchMyProfile()
    }
}
