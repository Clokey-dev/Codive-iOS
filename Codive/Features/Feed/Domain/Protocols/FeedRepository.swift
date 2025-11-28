//
//  FeedRepository.swift
//  Codive
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation

protocol FeedRepository {
    /// Feed 목록을 페이지 단위로 가져옵니다.
    /// - Parameters:
    ///   - page: 페이지 번호 (1부터 시작)
    ///   - limit: 한 페이지당 가져올 개수
    ///   - styleIds: 스타일 필터 (nil 또는 빈 배열이면 전체)
    ///   - situationIds: 상황 필터 (nil 또는 빈 배열이면 전체)
    ///   - followingOnly: 팔로잉한 사용자만 (기본값: false)
    /// - Returns: Feed 배열
    func fetchFeeds(
        page: Int,
        limit: Int,
        styleIds: [Int]?,
        situationIds: [Int]?,
        followingOnly: Bool
    ) async throws -> [Feed]

    /// 특정 Feed의 상세 정보를 가져옵니다.
    /// - Parameter id: Feed ID
    /// - Returns: Feed 상세 정보
    func fetchFeedDetail(id: Int) async throws -> Feed
}
