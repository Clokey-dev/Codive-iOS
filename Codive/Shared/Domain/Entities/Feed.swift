//
//  Feed.swift
//  Codive
//
//  Created by 황상환 on 11/25/25.
//

import Foundation

// MARK: - Feed
public struct Feed: Identifiable, Codable, Equatable {
    public let id: Int
    public let content: String?
    public let author: User?
    public let images: [FeedImage]

    public let situationId: Int?
    public let styleIds: [Int]?
    public let hashtags: [String]?
    public let createdAt: Date?

    // 상호작용 (목록/상세 공통)
    public let likeCount: Int? // 상세 조회에서 사용
    public let isLiked: Bool?
    public let commentCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, content, author, situationId, styleIds, hashtags, createdAt
        case images = "payloads"
        case likeCount, isLiked, commentCount
    }

    public init(
        id: Int,
        content: String?,
        author: User? = nil,
        images: [FeedImage],
        situationId: Int? = nil,
        styleIds: [Int]? = nil,
        hashtags: [String]? = nil,
        createdAt: Date? = nil,
        likeCount: Int? = nil,
        isLiked: Bool? = nil,
        commentCount: Int? = nil
    ) {
        self.id = id
        self.content = content
        self.author = author
        self.images = images
        self.situationId = situationId
        self.styleIds = styleIds
        self.hashtags = hashtags
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.commentCount = commentCount
    }
}

// MARK: - FeedImage
public struct FeedImage: Identifiable, Codable, Equatable {
    public let id: UUID = UUID()
    public let imageUrl: String
    public let tags: [ImageClothTag]
    
    enum CodingKeys: String, CodingKey {
        case imageUrl
        case tags = "clothTags"
    }
    
    public init(imageUrl: String, tags: [ImageClothTag] = []) {
        self.imageUrl = imageUrl
        self.tags = tags
    }
}

// MARK: - ImageClothTag
public struct ImageClothTag: Identifiable, Codable, Equatable {
    public let id: UUID = UUID()
    
    public let clothId: Int
    public let locationX: Double
    public let locationY: Double
    
    enum CodingKeys: String, CodingKey {
        case clothId, locationX, locationY
    }
    
    public init(clothId: Int, locationX: Double, locationY: Double) {
        self.clothId = clothId
        self.locationX = locationX
        self.locationY = locationY
    }
}
