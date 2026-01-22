//
//  Comment.swift
//  Codive
//
//  Created by 황상환 on 12/5/25.
//

import Foundation
import CodiveAPI

public struct Comment: Identifiable, Equatable {
    public let id: Int
    public let content: String
    public let author: User
    public let isMine: Bool

    // 댓글(Parent) 전용 필드
    public let hasReplies: Bool

    // UI 상태 관리를 위한 필드
    public var replies: [Comment]?

    public init(
        id: Int,
        content: String,
        author: User,
        isMine: Bool,
        hasReplies: Bool = false,
        replies: [Comment]? = nil
    ) {
        self.id = id
        self.content = content
        self.author = author
        self.isMine = isMine
        self.hasReplies = hasReplies
        self.replies = replies
    }
}

// MARK: - API 매핑
extension Comment {
    /// CodiveAPI의 CommentListResponse를 Comment로 변환
    static func from(apiResponse: Components.Schemas.CommentListResponse) -> Comment {
        let user = User(
            id: String(apiResponse.memberId ?? 0),
            nickname: apiResponse.nickName ?? "",
            profileImageUrl: apiResponse.profileImageUrl
        )

        return Comment(
            id: Int(apiResponse.commentId ?? 0),
            content: apiResponse.content ?? "",
            author: user,
            isMine: apiResponse.isMine ?? false,
            hasReplies: apiResponse.replied ?? false,
            replies: []
        )
    }

    /// CodiveAPI의 ReplyListResponse를 Comment로 변환
    static func from(apiResponse: Components.Schemas.ReplyListResponse) -> Comment {
        let user = User(
            id: String(apiResponse.memberId ?? 0),
            nickname: apiResponse.nickName ?? "",
            profileImageUrl: apiResponse.profileImageUrl
        )

        return Comment(
            id: Int(apiResponse.replyId ?? 0),
            content: apiResponse.content ?? "",
            author: user,
            isMine: apiResponse.isMine ?? false,
            hasReplies: false,
            replies: []
        )
    }
}
