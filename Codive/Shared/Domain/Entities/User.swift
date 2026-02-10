//
//  User.swift
//  Codive
//
//  Created by 황상환 on 11/25/25.
//

import Foundation

public struct User: Identifiable, Equatable, Hashable {
    
    public let id: String
    public let nickname: String
    public let profileImageUrl: String?
    
    public let bio: String?
    public let followerCount: Int?
    public let followingCount: Int?
    
    public let isFollowing: Bool?
    public let isMe: Bool?
    
    public init(
        id: String,
        nickname: String,
        profileImageUrl: String? = nil,
        bio: String? = nil,
        followerCount: Int? = nil,
        followingCount: Int? = nil,
        isFollowing: Bool? = nil,
        isMe: Bool? = nil
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.bio = bio
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.isFollowing = isFollowing
        self.isMe = isMe
    }
}
