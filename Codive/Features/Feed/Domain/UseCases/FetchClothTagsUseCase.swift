//
//  FetchClothTagsUseCase.swift
//  Codive
//
//  Created by 황상환 on 2026/01/22.
//

import Foundation

protocol FetchClothTagsUseCase {
    func execute(historyImageId: Int64) async throws -> [ClothTag]
}

final class DefaultFetchClothTagsUseCase: FetchClothTagsUseCase {

    // MARK: - Properties
    private let feedRepository: FeedRepository

    // MARK: - Initializer
    init(feedRepository: FeedRepository) {
        self.feedRepository = feedRepository
    }

    // MARK: - FetchClothTagsUseCase
    func execute(historyImageId: Int64) async throws -> [ClothTag] {
        return try await feedRepository.fetchClothTags(historyImageId: historyImageId)
    }
}
