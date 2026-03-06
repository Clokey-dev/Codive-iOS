//
//  ProfileEntity.swift
//  Codive
//
//  Created by 황상환 on 1/25/26.
//

struct MyProfileInfo: Codable {
    let userId: Int
    let nickname: String
    let displayName: String
    let introduction: String?
    let profileImageUrl: String?
    let followerCount: Int
    let followingCount: Int
    let email: String?
    let isPublic: Bool
}

struct FollowMember {
    let user: SimpleUser
    let isFollowing: Bool
    let isMe: Bool
}

struct FollowListResult {
    let followers: [FollowMember]
    let isLast: Bool
}
