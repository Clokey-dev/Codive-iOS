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
    
    private let commentRepository: CommentRepository
    
    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }
    
    @discardableResult
    func execute(feedId: Int, content: String) async throws -> Comment {
        return try await commentRepository.postComment(feedId: feedId, content: content)
    }
}
