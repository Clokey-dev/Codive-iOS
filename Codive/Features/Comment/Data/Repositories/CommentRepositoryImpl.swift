//
//  CommentRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation

final class CommentRepositoryImpl: CommentRepository {
    
    // MARK: - Properties
    private let dataSource: CommentDataSource
    
    // MARK: - Initializer
    init(dataSource: CommentDataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: - CommentRepository
    func fetchComments(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool) {
        return try await dataSource.fetchComments(feedId: feedId, page: page)
    }
    
    func postComment(feedId: Int, content: String) async throws -> Comment {
        return try await dataSource.postComment(feedId: feedId, content: content)
    }

    func fetchReplies(commentId: Int, page: Int) async throws -> (replies: [Comment], hasNext: Bool) {
        return try await dataSource.fetchReplies(commentId: commentId, page: page)
    }

    func postReply(feedId: Int, commentId: Int, content: String) async throws -> Comment {
        return try await dataSource.postReply(feedId: feedId, commentId: commentId, content: content)
    }
}
