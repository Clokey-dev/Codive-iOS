//
//  PostCommentUseCase.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation

protocol PostCommentUseCase {
    @discardableResult
    func execute(feedId: Int, content: String) async throws -> Comment
}

final class DefaultPostCommentUseCase: PostCommentUseCase {
    
    // MARK: - Properties
    private let commentRepository: CommentRepository
    
    // MARK: - Initializer
    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }
    
    // MARK: - PostCommentUseCase
    @discardableResult
    func execute(feedId: Int, content: String) async throws -> Comment {
        return try await commentRepository.postComment(feedId: feedId, content: content)
    }
}
