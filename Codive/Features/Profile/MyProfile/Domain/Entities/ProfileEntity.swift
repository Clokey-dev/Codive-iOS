//
//  ProfileEntity.swift
//  Codive
//
//  Created by Claude on 1/25/26.
//

struct MyProfileInfo {
    let userId: Int
    let nickname: String
    let displayName: String
    let introduction: String?
    let profileImageUrl: String?
    let followerCount: Int
    let followingCount: Int
}

struct FollowListResult {
    let followers: [SimpleUser]
    let isLast: Bool
}
