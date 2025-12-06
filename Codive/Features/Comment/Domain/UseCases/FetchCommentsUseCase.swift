//
//  FetchCommentsUseCase.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation

protocol FetchCommentsUseCase {
    func execute(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool)
}

final class DefaultFetchCommentsUseCase: FetchCommentsUseCase {
    
    private let commentRepository: CommentRepository
    
    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }
    
    func execute(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool) {
        return try await commentRepository.fetchComments(feedId: feedId, page: page)
    }
}
