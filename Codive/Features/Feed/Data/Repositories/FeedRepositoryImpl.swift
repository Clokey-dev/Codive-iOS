//
//  FeedRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation

/// FeedRepository의 구현체
/// DataSource로부터 데이터를 가져와서 Domain Layer에 제공
final class FeedRepositoryImpl: FeedRepository {
    private let dataSource: FeedDataSource

    init(dataSource: FeedDataSource) {
        self.dataSource = dataSource
    }

    func fetchFeeds(
        cursor: String? = nil,
        limit: Int,
        styleIds: [Int]? = nil,
        situationIds: [Int]? = nil,
        followingOnly: Bool = false
    ) async throws -> FeedPageResult {
        return try await dataSource.fetchFeeds(
            cursor: cursor,
            limit: limit,
            styleIds: styleIds,
            situationIds: situationIds,
            followingOnly: followingOnly
        )
    }

    func fetchFeedDetail(feedId: Int) async throws -> Feed {
        return try await dataSource.fetchFeedDetail(id: feedId)
    }

    func toggleLike(feedId: Int) async throws {
        try await dataSource.toggleLike(feedId: feedId)
    }

    func fetchLikers(feedId: Int) async throws -> [User] {
        return try await dataSource.fetchLikers(feedId: feedId)
    }
}
