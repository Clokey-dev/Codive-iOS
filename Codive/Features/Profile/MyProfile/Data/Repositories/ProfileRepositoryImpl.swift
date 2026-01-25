//
//  ProfileRepositoryImpl.swift
//  Codive
//
//  Created by Claude on 1/25/26.
//

final class ProfileRepositoryImpl: ProfileRepository {
    private let dataSource: ProfileDataSourceProtocol

    init(dataSource: ProfileDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func fetchMyProfile() async throws -> MyProfileInfo {
        return try await dataSource.fetchMyProfile()
    }

    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult {
        return try await dataSource.fetchFollows(memberId: memberId, isFollowing: isFollowing, lastFollowId: lastFollowId, size: size)
    }
}
