//
//  SettingDTOMapper.swift
//  Codive
//

import Foundation

// Domain entities
// DTOs

struct SettingDTOMapper {

    // MARK: - My Comments
    static func mapHistoryDTOToMyComment(_ dto: HistoryDTO, with dateFormatter: DateFormatter) -> MyComment {
        let author = SimpleUser(
            userId: UserID(dto.historyId),
            nickname: dto.nickname,
            handle: "",
            avatarURL: nil
        )

        let historyDate = dateFormatter.date(from: dto.historyDate) ?? Date()

        let replies = dto.payloads.map { payload in
            CommentReply(
                replyId: CommentID(payload.commentId),
                author: SimpleUser(
                    userId: UserID(payload.commentId),
                    nickname: "",
                    handle: "",
                    avatarURL: nil
                ),
                content: payload.content,
                createdAt: historyDate
            )
        }

        return MyComment(
            commentId: CommentID(dto.historyId),
            postId: PostID(dto.historyId),
            author: author,
            contentPreview: dto.content,
            createdAt: historyDate,
            replies: replies
        )
    }

    // MARK: - Liked Records
    static func mapLikedHistoryDTOToLikedRecord(_ dto: LikedHistoryDTO, with dateFormatter: DateFormatter) -> LikedRecord {
        let url = URL(string: dto.imageUrl) ?? URL(fileURLWithPath: "")
        let historyDate = dateFormatter.date(from: dto.historyDate) ?? Date()

        return LikedRecord(
            id: dto.id,
            thumbnailURL: url,
            historyDate: historyDate,
            lastLikeId: dto.lastLikeId ?? 0
        )
    }

    // MARK: - Blocked Users
    static func mapBlockedMemberDTOToBlockedUser(_ dto: BlockedMemberDTO, with dateFormatter: DateFormatter) -> BlockedUser {
        let avatarURL = dto.profileImageUrl.flatMap { URL(string: $0) }
        let author = SimpleUser(
            userId: UserID(Int(dto.userId)),
            nickname: dto.nickname,
            handle: "",
            avatarURL: avatarURL
        )
        let blockedDate = dateFormatter.date(from: dto.blockedAt) ?? Date()

        return BlockedUser(user: author, blockedAt: blockedDate)
    }
}
