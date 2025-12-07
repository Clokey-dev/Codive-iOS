//
//  CommentDataSource.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation

// MARK: - Protocol
protocol CommentDataSource {
    func fetchComments(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool)
    func postComment(feedId: Int, content: String) async throws -> Comment
}

// MARK: - Mock Implementation
final class MockCommentDataSource: CommentDataSource {
    func fetchComments(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool) {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if page == 0 {
            return (comments: CommentMockData.comments, hasNext: true)
        } else {
            return (comments: [], hasNext: false)
        }
    }
    
    func postComment(feedId: Int, content: String) async throws -> Comment {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let newComment = Comment(
            id: Int.random(in: 100...999),
            content: content,
            author: CommentMockData.users[2], // "CurrentUser"
            isMine: true
        )
        return newComment
    }
}
