//
//  FetchFeedDetailUseCase.swift
//  Codive
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation

/// Feed 상세 정보를 가져오는 UseCase
protocol FetchFeedDetailUseCase {
    /// 특정 Feed의 상세 정보 조회
    /// - Parameter feedId: Feed ID
    /// - Returns: Feed 상세 정보
    func execute(feedId: Int) async throws -> Feed
}

final class DefaultFetchFeedDetailUseCase: FetchFeedDetailUseCase {
    private let repository: FeedRepository

    init(repository: FeedRepository) {
        self.repository = repository
    }

    func execute(feedId: Int) async throws -> Feed {
        return try await repository.fetchFeedDetail(feedId: feedId)
    }
}
