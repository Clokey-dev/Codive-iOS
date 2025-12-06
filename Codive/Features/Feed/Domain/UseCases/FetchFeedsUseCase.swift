//
//  FetchFeedsUseCase.swift
//  Codive
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation

/// Feed 목록을 가져오는 UseCase
protocol FetchFeedsUseCase {
    /// Feed 목록을 페이지 단위로 조회
    /// - Parameters:
    ///   - page: 페이지 번호 (1부터 시작)
    ///   - limit: 한 페이지당 가져올 개수
    ///   - styleIds: 스타일 필터 (nil 또는 빈 배열이면 전체)
    ///   - situationIds: 상황 필터 (nil 또는 빈 배열이면 전체)
    ///   - followingOnly: 팔로잉한 사용자만 (기본값: false)
    /// - Returns: Feed 배열
    func execute(
        page: Int,
        limit: Int,
        styleIds: [Int]?,
        situationIds: [Int]?,
        followingOnly: Bool
    ) async throws -> [Feed]
}

final class DefaultFetchFeedsUseCase: FetchFeedsUseCase {
    private let repository: FeedRepository

    init(repository: FeedRepository) {
        self.repository = repository
    }

    func execute(
        page: Int,
        limit: Int,
        styleIds: [Int]? = nil,
        situationIds: [Int]? = nil,
        followingOnly: Bool = false
    ) async throws -> [Feed] {
        return try await repository.fetchFeeds(
            page: page,
            limit: limit,
            styleIds: styleIds,
            situationIds: situationIds,
            followingOnly: followingOnly
        )
    }
}
