//
//  FetchRepliesUseCase.swift
//  Codive
//
//  Created by 황상환 on 2025/12/22.
//

import Foundation

protocol FetchRepliesUseCase {
    func execute(commentId: Int, page: Int) async throws -> (replies: [Comment], hasNext: Bool)
}

final class DefaultFetchRepliesUseCase: FetchRepliesUseCase {

    // MARK: - Properties
    private let commentRepository: CommentRepository

    // MARK: - Initializer
    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    // MARK: - FetchRepliesUseCase
    func execute(commentId: Int, page: Int) async throws -> (replies: [Comment], hasNext: Bool) {
        return try await commentRepository.fetchReplies(commentId: commentId, page: page)
    }
}
