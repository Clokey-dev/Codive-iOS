import Foundation

// 유저 간단 정보
public struct SimpleUser: Hashable, Sendable {
    public let userId: UserID
    public let nickname: String
    public let handle: String
    public let avatarURL: URL?
    public init(userId: UserID, nickname: String, handle: String, avatarURL: URL?) {
        self.userId = userId
        self.nickname = nickname
        self.handle = handle
        self.avatarURL = avatarURL
    }
}

// 좋아요한 기록
public struct LikedRecord: Hashable, Sendable, Identifiable {
    public let id: Int64
    public let thumbnailURL: URL
    public let historyDate: Date
    public let lastLikeId: Int64

    public init(id: Int64, thumbnailURL: URL, historyDate: Date, lastLikeId: Int64) {
        self.id = id
        self.thumbnailURL = thumbnailURL
        self.historyDate = historyDate
        self.lastLikeId = lastLikeId
    }
}

// 댓글에 달린 답글
public struct CommentReply: Hashable, Sendable, Identifiable {
    public var id: CommentID { replyId }
    public let replyId: CommentID
    public let author: SimpleUser
    public let content: String
    public let createdAt: Date

    public init(
        replyId: CommentID,
        author: SimpleUser,
        content: String,
        createdAt: Date
    ) {
        self.replyId = replyId
        self.author = author
        self.content = content
        self.createdAt = createdAt
    }
}

// 내가 남긴 댓글
public struct MyComment: Hashable, Sendable, Identifiable {
    public var id: CommentID { commentId }
    public let commentId: CommentID
    public let postId: PostID
    public let author: SimpleUser
    public let contentPreview: String
    public let createdAt: Date
    public let replies: [CommentReply]

    public init(
        commentId: CommentID,
        postId: PostID,
        author: SimpleUser,
        contentPreview: String,
        createdAt: Date,
        replies: [CommentReply] = []
    ) {
        self.commentId = commentId
        self.postId = postId
        self.author = author
        self.contentPreview = contentPreview
        self.createdAt = createdAt
        self.replies = replies
    }
}

// 차단한 계정
public struct BlockedUser: Hashable, Sendable, Identifiable {
    public var id: UserID { user.userId }
    public let user: SimpleUser
    public let blockedAt: Date
    public init(user: SimpleUser, blockedAt: Date) {
        self.user = user
        self.blockedAt = blockedAt
    }
}

// 알림 환경설정
// 푸시 알림 여부
public struct NotificationPrefs: Equatable, Sendable {
    public var pushEnabled: Bool
    public var marketingOptIn: Bool

    public init(pushEnabled: Bool, marketingOptIn: Bool) {
        self.pushEnabled = pushEnabled
        self.marketingOptIn = marketingOptIn
    }
}
// 탈퇴 안내
public struct WithdrawNotice: Sendable, Hashable {
    public let title: String
    public let body: String
    public init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}
