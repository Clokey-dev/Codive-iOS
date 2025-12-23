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
    
    // MARK: - Properties
    private let commentRepository: CommentRepository
    
    // MARK: - Initializer
    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }
    
    // MARK: - FetchCommentsUseCase
    func execute(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool) {
        return try await commentRepository.fetchComments(feedId: feedId, page: page)
    }
}
