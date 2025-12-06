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
            return (comments: mockComments, hasNext: true)
        } else {
            return (comments: [], hasNext: false)
        }
    }
    
    func postComment(feedId: Int, content: String) async throws -> Comment {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let newComment = Comment(
            id: Int.random(in: 100...999),
            content: content,
            author: mockUsers[2], // "CurrentUser"
            isMine: true
        )
        return newComment
    }
}

// MARK: - Mock Data
private let mockUsers: [User] = [
    .init(id: "1", nickname: "패셔니스타", profileImageUrl: "https://example.com/p1.jpg"),
    .init(id: "2", nickname: "코디장인", profileImageUrl: "https://example.com/p2.jpg"),
    .init(id: "3", nickname: "CurrentUser", profileImageUrl: nil),
    .init(id: "4", nickname: "궁금러", profileImageUrl: "https://example.com/p4.jpg")
]

private let mockComments: [Comment] = [
    {
        var comment = Comment(id: 1, content: "와, 이 코디 정말 멋져요! 어디서 구매하셨나요?", author: mockUsers[0], isMine: false, hasReplies: true)
        comment.replies = [
            .init(id: 101, content: "그러게요! 저도 궁금해요!", author: mockUsers[1], isMine: false),
            .init(id: 102, content: "상의 정보 알 수 있을까요?", author: mockUsers[0], isMine: true),
            .init(id: 103, content: "DM 확인해주세요~", author: mockUsers[3], isMine: false),
            .init(id: 104, content: "네, 확인했어요!", author: mockUsers[0], isMine: true)
        ]
        return comment
    }(),
    .init(id: 2, content: "신발 정보 좀 알 수 있을까요? 🥹", author: mockUsers[1], isMine: false, hasReplies: false)
]
