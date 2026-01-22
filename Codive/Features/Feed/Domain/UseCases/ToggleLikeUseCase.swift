//
//  ToggleLikeUseCase.swift
//  Codive
//
//  Created by Claude on 2026/01/22.
//

import Foundation

protocol ToggleLikeUseCase {
    func execute(feedId: Int) async throws
}

final class DefaultToggleLikeUseCase: ToggleLikeUseCase {

    // MARK: - Properties
    private let feedRepository: FeedRepository

    // MARK: - Initializer
    init(feedRepository: FeedRepository) {
        self.feedRepository = feedRepository
    }

    // MARK: - ToggleLikeUseCase
    func execute(feedId: Int) async throws {
        try await feedRepository.toggleLike(feedId: feedId)
    }
}
