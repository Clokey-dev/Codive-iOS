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
    public var replyCount: Int?

    // UI 상태 관리를 위한 필드
    public var replies: [Comment]?
    public var replyPage: Int = 0
    public var hasMoreReplies: Bool = true

    public init(
        id: Int,
        content: String,
        author: User,
        isMine: Bool,
        hasReplies: Bool = false,
        replyCount: Int? = nil,
        replies: [Comment]? = nil,
        replyPage: Int = 0,
        hasMoreReplies: Bool = true
    ) {
        self.id = id
        self.content = content
        self.author = author
        self.isMine = isMine
        self.hasReplies = hasReplies
        self.replyCount = replyCount
        self.replies = replies
        self.replyPage = replyPage
        self.hasMoreReplies = hasMoreReplies
    }
}

// MARK: - API 매핑
extension Comment {
    /// CodiveAPI의 CommentListResponse를 Comment로 변환
    static func from(apiResponse: Components.Schemas.CommentListResponse) -> Comment {
        let user = User(
            id: String(apiResponse.memberId ?? 0),
            nickname: apiResponse.nickname ?? "",
            profileImageUrl: apiResponse.profileImageUrl
        )

        return Comment(
            id: Int(apiResponse.commentId ?? 0),
            content: apiResponse.content ?? "",
            author: user,
            isMine: apiResponse.isMine ?? false,
            hasReplies: apiResponse.replied ?? false,
            replyCount: apiResponse.replyCount.flatMap { Int($0) },
            replies: nil
        )
    }

    /// CodiveAPI의 ReplyListResponse를 Comment로 변환
    static func from(apiResponse: Components.Schemas.ReplyListResponse) -> Comment {
        let user = User(
            id: String(apiResponse.memberId ?? 0),
            nickname: apiResponse.nickname ?? "",
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
