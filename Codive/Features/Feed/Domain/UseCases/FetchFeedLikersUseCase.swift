//
//  FetchFeedLikersUseCase.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation

protocol FetchFeedLikersUseCase {
    func execute(feedId: Int) async throws -> [User]
}

final class DefaultFetchFeedLikersUseCase: FetchFeedLikersUseCase {
    
    // MARK: - Properties
    private let feedRepository: FeedRepository
    
    // MARK: - Initializer
    init(feedRepository: FeedRepository) {
        self.feedRepository = feedRepository
    }
    
    // MARK: - FetchFeedLikersUseCase
    func execute(feedId: Int) async throws -> [User] {
        return try await feedRepository.fetchLikers(feedId: feedId)
    }
}
