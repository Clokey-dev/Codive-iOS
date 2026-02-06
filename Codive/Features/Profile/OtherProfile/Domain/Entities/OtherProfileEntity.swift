//
//  OtherProfileEntity.swift
//  Codive
//
//  Created by 황상환 on 2026-02-05.
//

import Foundation

public struct OtherProfileEntity: Equatable {
    public let memberId: Int
    public let nickname: String
    public let bio: String?
    public let followerCount: Int
    public let followingCount: Int
    public let profileImageUrl: String?
    public let isPublic: Bool
    public let isFollowing: Bool
    public let isMe: Bool

    public init(
        memberId: Int,
        nickname: String,
        bio: String?,
        followerCount: Int,
        followingCount: Int,
        profileImageUrl: String?,
        isPublic: Bool,
        isFollowing: Bool,
        isMe: Bool
    ) {
        self.memberId = memberId
        self.nickname = nickname
        self.bio = bio
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.profileImageUrl = profileImageUrl
        self.isPublic = isPublic
        self.isFollowing = isFollowing
        self.isMe = isMe
    }
}
