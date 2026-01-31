//
//  FetchFollowsUseCase.swift
//  Codive
//
//  Created by 황상환 on 1/25/26.
//

protocol FetchFollowsUseCase {
    func execute(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult
}

final class DefaultFetchFollowsUseCase: FetchFollowsUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult {
        return try await repository.fetchFollows(memberId: memberId, isFollowing: isFollowing, lastFollowId: lastFollowId, size: size)
    }
}
