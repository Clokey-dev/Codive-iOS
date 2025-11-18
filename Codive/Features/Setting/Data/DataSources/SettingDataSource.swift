//
//  SettingsDataSource.swift
//  Codive
//

import Foundation

/// 네트워크 붙기 전까지 사용할 인메모리 스텁
final class SettingsDataSource {

    // MARK: - In-memory stores
    private var likedRecordsStore: [LikedRecord] = []
    private var myCommentsStore: [MyComment] = []
    private var blockedUsersStore: [BlockedUser] = []
    private var notificationPrefsStore: NotificationPrefs = .init(
        pushEnabled: true,
        marketingOptIn: false
    )

    private let withdrawNoticesStore: [WithdrawNotice] = [
        .init(title: "데이터 삭제 안내",
              body: "탈퇴 시 계정 및 개인정보는 복구가 불가합니다."),
        .init(title: "게시물 처리",
              body: "작성한 게시물/댓글은 정책에 따라 익명화되거나 삭제될 수 있습니다.")
    ]

    // MARK: - Init (샘플 데이터)
    init() {
        likedRecordsStore = (1...25).compactMap { i in
            let urlString = "https://picsum.photos/id/\(i % 100)/200/200"
            guard let url = URL(string: urlString) else {
                assertionFailure("Stub URL invalid: \(urlString)")
                return nil        // 잘못된 건 그냥 버림 (더미 데이터니까)
            }

            return LikedRecord(
                postId: PostID(i),
                thumbnailURL: url,
                likedAt: Date().addingTimeInterval(TimeInterval(-i * 1_800))
            )
        }

        // 내가 남긴 댓글 (엔티티 시그니처에 맞춰 author/preview 포함)
        myCommentsStore = (1...17).map { i in
            let author = SimpleUser(
                userId: UserID(300 + i),
                nickname: "닉네임\(i)",
                handle: "user_\(i)",
                avatarURL: nil
            )
            return MyComment(
                commentId: CommentID(i),
                postId: PostID(10 + i),
                author: author,
                contentPreview: "내 댓글 내용 \(i)",
                createdAt: Date().addingTimeInterval(TimeInterval(-i * 3_600))
            )
        }

        // 차단한 계정
        let u1 = SimpleUser(userId: UserID(101), nickname: "차단유저A", handle: "user_a", avatarURL: nil)
        let u2 = SimpleUser(userId: UserID(202), nickname: "차단유저B", handle: "user_b", avatarURL: nil)
        blockedUsersStore = [
            BlockedUser(user: u1, blockedAt: Date().addingTimeInterval(-86_400)),
            BlockedUser(user: u2, blockedAt: Date().addingTimeInterval(-172_800))
        ]
    }

    // MARK: - Liked Records
    func fetchLikedRecords(page: Int, pageSize: Int) async throws -> [LikedRecord] {
        guard page > 0, pageSize > 0 else { return [] }
        let start = (page - 1) * pageSize
        let end = min(start + pageSize, likedRecordsStore.count)
        guard start < end else { return [] }
        return Array(likedRecordsStore[start..<end])
    }

    // MARK: - My Comments
    func fetchMyComments(page: Int, pageSize: Int) async throws -> [MyComment] {
        guard page > 0, pageSize > 0 else { return [] }
        let start = (page - 1) * pageSize
        let end = min(start + pageSize, myCommentsStore.count)
        guard start < end else { return [] }
        return Array(myCommentsStore[start..<end])
    }

    // MARK: - Blocked Users
    func fetchBlockedUsers() async throws -> [BlockedUser] {
        blockedUsersStore
    }

    func unblock(userId: UserID) async throws {
        if let idx = blockedUsersStore.firstIndex(where: { $0.id == userId }) {
            blockedUsersStore.remove(at: idx)
        }
    }

    // MARK: - Notification Prefs
    func getNotificationPrefs() async throws -> NotificationPrefs {
        notificationPrefsStore
    }

    func updateNotificationPrefs(_ prefs: NotificationPrefs) async throws {
        notificationPrefsStore = prefs
    }

    // MARK: - Withdraw
    func getWithdrawNotices() async throws -> [WithdrawNotice] {
        withdrawNoticesStore
    }

    func withdrawAccount() async throws {
        // 실제 구현 시 서버 요청/토큰 폐기/캐시 정리 등 수행
    }
}
