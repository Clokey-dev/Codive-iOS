//
//  MockCommentRepository.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation
import Combine

final class MockCommentRepository: CommentRepository {

    func fetchComments(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool) {
        // 0.2초 딜레이
        try await Task.sleep(nanoseconds: 200_000_000)

        // 페이지가 0일 때만 가짜 데이터를 반환하고, 그 이후 페이지는 없다고 가정
        if page == 0 {
            return (comments: CommentMockData.comments, hasNext: true)
        } else {
            return (comments: [], hasNext: false)
        }
    }

    @discardableResult
    func postComment(feedId: Int, content: String) async throws -> Comment {
        try await Task.sleep(nanoseconds: 300_000_000)

        let newComment = Comment(
            id: Int.random(in: 100...999),
            content: content,
            author: CommentMockData.users[2],
            isMine: true,
            hasReplies: false
        )
        return newComment
    }

    func fetchReplies(commentId: Int, page: Int) async throws -> (replies: [Comment], hasNext: Bool) {
        try await Task.sleep(nanoseconds: 200_000_000)

        if page == 0 {
            return (replies: CommentMockData.comments.suffix(2).map { comment in
                Comment(
                    id: comment.id + 1000,
                    content: comment.content,
                    author: comment.author,
                    isMine: false,
                    hasReplies: false
                )
            }, hasNext: false)
        } else {
            return (replies: [], hasNext: false)
        }
    }

    @discardableResult
    func postReply(feedId: Int, commentId: Int, content: String) async throws -> Comment {
        try await Task.sleep(nanoseconds: 300_000_000)

        let newReply = Comment(
            id: Int.random(in: 1000...9999),
            content: content,
            author: CommentMockData.users[2],
            isMine: true,
            hasReplies: false
        )
        return newReply
    }

    func deleteComment(commentId: Int) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
}
