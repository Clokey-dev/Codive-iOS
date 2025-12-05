//
//  Comment.swift
//  Codive
//
//  Created by 황상환 on 12/5/25.
//

import Foundation

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
