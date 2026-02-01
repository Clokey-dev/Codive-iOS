//
//  SettingsDataSource.swift
//  Codive
//

import Foundation
import CodiveAPI

final class SettingsDataSource {

    // MARK: - Properties
    private let apiClient: Client

    // MARK: - In-memory stores
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

    // MARK: - Init
    init(apiClient: Client = CodiveAPIProvider.createClient()) {
        self.apiClient = apiClient

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
        let lastLikeId: Int64? = page > 1 ? Int64((page - 1) * pageSize) : nil
        let jsonDecoder = JSONDecoderFactory.makeAPIDecoder()

        let response = try await apiClient.Like_getLikedHistories(
            query: .init(lastLikeId: lastLikeId, size: Int32(pageSize))
        )

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)

            struct LikedRecordsResult: Decodable {
                let content: [LikedHistoryDTO]
                let isLast: Bool
            }

            struct LikedRecordsAPIResponse: Decodable {
                let isSuccess: Bool
                let code: String
                let message: String
                let timeStamp: String
                let result: LikedRecordsResult
            }

            let apiResponse = try jsonDecoder.decode(LikedRecordsAPIResponse.self, from: data)

            guard apiResponse.isSuccess else {
                throw SettingError.apiError(message: apiResponse.message)
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")

            return apiResponse.result.content.map { dto in
                SettingDTOMapper.mapLikedHistoryDTOToLikedRecord(dto, with: dateFormatter)
            }

        default:
            if case .undocumented(let statusCode, let payload) = response {
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let responseBody = String(data: data, encoding: .utf8) {
                        print("fetchLikedRecords error response [\(statusCode)]: \(responseBody)")
                    }
                }
            }
            throw SettingError.networkError
        }
    }

    // MARK: - My Comments
    func fetchMyComments(page: Int, pageSize: Int) async throws -> [MyComment] {
        let lastHistoryId: Int64? = page > 1 ? Int64((page - 1) * pageSize) : nil
        let jsonDecoder = JSONDecoderFactory.makeAPIDecoder()

        let response = try await apiClient.Comment_getMyComments(
            query: .init(lastHistoryId: lastHistoryId, size: Int32(pageSize))
        )

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)

            let apiResponse = try jsonDecoder.decode(MyCommentsAPIResponse.self, from: data)

            guard apiResponse.isSuccess else {
                throw SettingError.apiError(message: apiResponse.message)
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")

            return apiResponse.result.content.map { historyDTO in
                SettingDTOMapper.mapHistoryDTOToMyComment(historyDTO, with: dateFormatter)
            }

        default:
            if case .undocumented(let statusCode, let payload) = response {
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let responseBody = String(data: data, encoding: .utf8) {
                        print("fetchMyComments error response [\(statusCode)]: \(responseBody)")
                    }
                }
            }
            throw SettingError.networkError
        }
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
