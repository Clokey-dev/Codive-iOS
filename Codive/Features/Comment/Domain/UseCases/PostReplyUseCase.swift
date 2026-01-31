//
//  PostReplyUseCase.swift
//  Codive
//
//  Created by 황상환 on 2025/12/22.
//

import Foundation

protocol PostReplyUseCase {
    @discardableResult
    func execute(feedId: Int, commentId: Int, content: String) async throws -> Comment
}

final class DefaultPostReplyUseCase: PostReplyUseCase {

    // MARK: - Properties
    private let commentRepository: CommentRepository

    // MARK: - Initializer
    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    // MARK: - PostReplyUseCase
    @discardableResult
    func execute(feedId: Int, commentId: Int, content: String) async throws -> Comment {
        return try await commentRepository.postReply(feedId: feedId, commentId: commentId, content: content)
    }
}
