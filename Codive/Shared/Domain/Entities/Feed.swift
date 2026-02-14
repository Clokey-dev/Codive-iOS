//
//  Feed.swift
//  Codive
//
//  Created by 황상환 on 11/25/25.
//

import Foundation

// MARK: - Type Aliases
public typealias FeedID = Int
public typealias ImageID = Int64
public typealias ClothID = Int

// MARK: - Feed
public struct Feed: Identifiable, Equatable, Hashable {
    public let id: FeedID
    public let content: String?
    public let author: User
    public let images: [FeedImage]

    public let situationId: Int?
    public let styleIds: [Int]?
    public let styleNames: [String]?
    public let hashtags: [String]?
    public let createdAt: Date?

    // 상호작용 (목록/상세 공통)
    public let likeCount: Int?
    public let isLiked: Bool?
    public let commentCount: Int?
    public init(
        id: Int,
        content: String?,
        author: User,
        images: [FeedImage],
        situationId: Int? = nil,
        styleIds: [Int]? = nil,
        styleNames: [String]? = nil,
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
        self.styleNames = styleNames
        self.hashtags = hashtags
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.commentCount = commentCount
    }
}

// MARK: - FeedImage
public struct FeedImage: Identifiable, Equatable, Hashable {
    public let id: UUID = UUID()
    public let imageId: ImageID?
    public let imageUrl: String
    public let tags: [ImageClothTag]

    public init(imageId: ImageID? = nil, imageUrl: String, tags: [ImageClothTag] = []) {
        self.imageId = imageId
        self.imageUrl = imageUrl
        self.tags = tags
    }
}

// MARK: - ImageClothTag
public struct ImageClothTag: Identifiable, Equatable, Hashable {
    public let id: UUID = UUID()

    public let clothId: ClothID
    public let locationX: Double
    public let locationY: Double

    public init(clothId: ClothID, locationX: Double, locationY: Double) {
        self.clothId = clothId
        self.locationX = locationX
        self.locationY = locationY
    }
}
