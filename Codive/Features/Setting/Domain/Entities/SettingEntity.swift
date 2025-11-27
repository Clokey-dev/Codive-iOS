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
    public let postId: PostID
    public let thumbnailURL: URL
    public let likedAt: Date
    public init(postId: PostID, thumbnailURL: URL, likedAt: Date) {
        self.postId = postId
        self.thumbnailURL = thumbnailURL
        self.likedAt = likedAt
    }
    public var id: PostID { postId }
}

// 내가 남긴 댓글
public struct MyComment: Hashable, Sendable, Identifiable {
    public var id: CommentID { commentId } 
    public let commentId: CommentID
    public let postId: PostID
    public let author: SimpleUser
    public let contentPreview: String
    public let createdAt: Date
    public init(
        commentId: CommentID,
        postId: PostID,
        author: SimpleUser,
        contentPreview: String,
        createdAt: Date
    ) {
        self.commentId = commentId
        self.postId = postId
        self.author = author
        self.contentPreview = contentPreview
        self.createdAt = createdAt
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
