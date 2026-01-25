//
//  ProfileRepository.swift
//  Codive
//
//  Created by Claude on 1/25/26.
//

protocol ProfileRepository {
    func fetchMyProfile() async throws -> MyProfileInfo
    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult
}
