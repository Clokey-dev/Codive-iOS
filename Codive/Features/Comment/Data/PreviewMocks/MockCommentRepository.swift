// Codive/Features/Comment/Data/PreviewMocks/MockCommentRepository.swift

import Foundation
import Combine

/// UI 미리보기 또는 테스트를 위한 `CommentRepository`의 Mock 구현체입니다.
final class MockCommentRepository: CommentRepository {
    
    func fetchComments(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool) {
        // 0.5초 딜레이를 주어 실제 네트워크처럼 보이게 합니다.
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // 페이지가 0일 때만 가짜 데이터를 반환하고, 그 이후 페이지는 없다고 가정합니다.
        if page == 0 {
            return (comments: mockComments, hasNext: true)
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
            author: mockUsers[2], // "CurrentUser"
            isMine: true,
            hasReplies: false
        )
        return newComment
    }
}


// MARK: - Mock Data

private let mockUsers: [User] = [
    .init(id: "1", nickname: "패셔니스타", profileImageUrl: nil),
    .init(id: "2", nickname: "코디장인", profileImageUrl: nil),
    .init(id: "3", nickname: "CurrentUser", profileImageUrl: nil),
]

private let mockComments: [Comment] = [
    .init(id: 1, content: "와, 이 코디 정말 멋져요! 어디서 구매하셨나요?", author: mockUsers[0], isMine: false, hasReplies: true, replies: [
        .init(id: 11, content: "그러게요! 저도 궁금해요!", author: mockUsers[1], isMine: false)
    ]),
    .init(id: 2, content: "신발 정보 좀 알 수 있을까요? 🥹", author: mockUsers[1], isMine: false, hasReplies: false),
    .init(id: 3, content: "제가 찾던 스타일인데 참고할게요~", author: mockUsers[0], isMine: false, hasReplies: false)
]
