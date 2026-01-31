//
//  FeedRepository.swift
//  Codive
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation

protocol FeedRepository {
    // MARK: - 피드 전체 조회 (커서 기반 페이지네이션)
    func fetchFeeds(
        cursor: String?,
        limit: Int,
        styleIds: [Int]?,
        situationIds: [Int]?,
        followingOnly: Bool
    ) async throws -> FeedPageResult

    // MARK: - 피드 상세 조회
    func fetchFeedDetail(feedId: Int) async throws -> Feed

    // MARK: - 좋아요 토글
    func toggleLike(feedId: Int) async throws

    // MARK: - 좋아요 누른 유저 목록 조회
    func fetchLikers(feedId: Int) async throws -> [User]

    // MARK: - 이미지의 옷 태그 조회
    func fetchClothTags(historyImageId: Int64) async throws -> [ClothTag]
}
