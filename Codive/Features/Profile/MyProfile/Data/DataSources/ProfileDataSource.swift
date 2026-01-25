//
//  ProfileDataSource.swift
//  Codive
//
//  Created by Claude on 1/25/26.
//

import Foundation

protocol ProfileDataSourceProtocol {
    func fetchMyProfile() async throws -> MyProfileInfo
    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult
}

final class ProfileDataSource: ProfileDataSourceProtocol {
    private let apiService: ProfileAPIServiceProtocol

    init(apiService: ProfileAPIServiceProtocol = ProfileAPIService()) {
        self.apiService = apiService
    }

    func fetchMyProfile() async throws -> MyProfileInfo {
        return try await apiService.fetchMyProfile()
    }

    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult {
        return try await apiService.fetchFollows(memberId: memberId, isFollowing: isFollowing, lastFollowId: lastFollowId, size: size)
    }
}
