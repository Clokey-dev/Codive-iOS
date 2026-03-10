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
    init(apiClient: Client = CodiveAPIProvider.createConfiguredClient()) {
        self.apiClient = apiClient
    }

    // MARK: - Liked Records
    func fetchLikedRecords(page: Int, pageSize: Int) async throws -> [LikedRecord] {
        let lastLikeId: Int64? = page > 1 ? Int64((page - 1) * pageSize) : nil

        let response = try await apiClient.Like_getLikedHistories(
            query: .init(lastLikeId: lastLikeId, size: Int32(pageSize))
        )

        switch response {
//        case .ok(let okResponse):
//            let httpBody = try okResponse.body.any
//            let data = try await Data(collecting: httpBody, upTo: .max)
//
//            struct LikedRecordsResult: Decodable {
//                let content: [LikedHistoryDTO]
//                let isLast: Bool
//            }
//
//            struct LikedRecordsAPIResponse: Decodable {
//                let isSuccess: Bool
//                let code: String
//                let message: String
//                let timeStamp: String
//                let result: LikedRecordsResult
//            }
//
//            let apiResponse = try jsonDecoder.decode(LikedRecordsAPIResponse.self, from: data)
//
//            guard apiResponse.isSuccess else {
//                throw SettingError.apiError(message: apiResponse.message)
//            }
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//
//            return apiResponse.result.content.map { dto in
//                SettingDTOMapper.mapLikedHistoryDTOToLikedRecord(dto, with: dateFormatter)
//            }
        case .ok(let okResponse):
            let apiResponse = try okResponse.body.json

            guard apiResponse.isSuccess == true else {
                throw SettingError.apiError(message: apiResponse.message ?? "Unknown error")
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")

            return apiResponse.result?.content?.map { item in
                let dto = LikedHistoryDTO(
                    id: item.id ?? 0,
                    imageUrl: item.imageUrl ?? "",
                    historyDate: item.historyDate ?? "",
                    lastLikeId: item.lastLikeId
                )
                return SettingDTOMapper.mapLikedHistoryDTOToLikedRecord(dto, with: dateFormatter)
            } ?? []

        default:
            if case .undocumented(let statusCode, let payload) = response {
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let responseBody = String(data: data, encoding: .utf8) {
                        #if DEBUG
                        print("[Setting] fetchLikedRecords error [\(statusCode)]: \(responseBody)")
                        #endif
                    }
                }
            }
            throw SettingError.networkError
        }
    }

    // MARK: - My Comments
    func fetchMyComments(page: Int, pageSize: Int) async throws -> [MyComment] {
        let lastHistoryId: Int64? = page > 1 ? Int64((page - 1) * pageSize) : nil

        let response = try await apiClient.Comment_getMyComments(
            query: .init(lastHistoryId: lastHistoryId, size: Int32(pageSize))
        )

        switch response {
//        case .ok(let okResponse):
//            let httpBody = try okResponse.body.any
//            let data = try await Data(collecting: httpBody, upTo: .max)
//
//            let apiResponse = try jsonDecoder.decode(MyCommentsAPIResponse.self, from: data)
//
//            guard apiResponse.isSuccess else {
//                throw SettingError.apiError(message: apiResponse.message)
//            }
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//
//            return apiResponse.result.content.map { historyDTO in
//                SettingDTOMapper.mapHistoryDTOToMyComment(historyDTO, with: dateFormatter)
//            }
        case .ok(let okResponse):
            let apiResponse = try okResponse.body.json

            guard apiResponse.isSuccess == true else {
                throw SettingError.apiError(message: apiResponse.message ?? "Unknown error")
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")

            return apiResponse.result?.content?.map { item in
                let payloads = item.payloads?.map { payload in
                    HistoryDTO.CommentPayloadDTO(
                        commentId: payload.commentId ?? 0,
                        content: payload.content
                    )
                } ?? []
                let historyDTO = HistoryDTO(
                    historyId: item.historyId ?? 0,
                    imageUrl: item.imageUrl ?? "",
                    nickname: item.nickname ?? "",
                    historyDate: item.historyDate ?? "",
                    content: item.content,
                    payloads: payloads
                )
                return SettingDTOMapper.mapHistoryDTOToMyComment(historyDTO, with: dateFormatter)
            } ?? []

        default:
            if case .undocumented(let statusCode, let payload) = response {
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let responseBody = String(data: data, encoding: .utf8) {
                        #if DEBUG
                        print("[Setting] fetchMyComments error [\(statusCode)]: \(responseBody)")
                        #endif
                    }
                }
            }
            throw SettingError.networkError
        }
    }

    // MARK: - Blocked Users
    func fetchBlockedUsers() async throws -> [BlockedUser] {
        let response = try await apiClient.Member_getBlockedMembers(
            query: .init(size: 500)
        )

        switch response {
//        case .ok(let okResponse):
//            let httpBody = try okResponse.body.any
//            let data = try await Data(collecting: httpBody, upTo: .max)
//
//            let apiResponse = try jsonDecoder.decode(BlockedMembersAPIResponse.self, from: data)
//
//            guard apiResponse.isSuccess else {
//                throw SettingError.apiError(message: apiResponse.message)
//            }
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//
//            return apiResponse.result.content.map { dto in
//                SettingDTOMapper.mapBlockedMemberDTOToBlockedUser(dto, with: dateFormatter)
//            }
        case .ok(let okResponse):
            let apiResponse = try okResponse.body.json

            guard apiResponse.isSuccess == true else {
                throw SettingError.apiError(message: apiResponse.message ?? "Unknown error")
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")

            return apiResponse.result?.content?.map { item in
                let dto = BlockedMemberDTO(
                    blockId: item.blockId ?? 0,
                    memberId: item.memberId ?? 0,
                    nickname: item.nickname ?? "",
                    profileImageUrl: item.profileImageUrl
                )
                return SettingDTOMapper.mapBlockedMemberDTOToBlockedUser(dto, with: dateFormatter)
            } ?? []

        default:
            if case .undocumented(let statusCode, let payload) = response {
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let responseBody = String(data: data, encoding: .utf8) {
                        #if DEBUG
                        print("[Setting] fetchBlockedUsers error [\(statusCode)]: \(responseBody)")
                        #endif
                    }
                }
            }
            throw SettingError.networkError
        }
    }

    func unblock(userId: UserID) async throws {
        // UserID (String)를 Int로 변환 후 Int64로 변환
        guard let userIdInt = Int(userId) else {
            throw SettingError.invalidUserId
        }

        // API 호출로 차단 해제
        let response = try await apiClient.Member_toggleBlockStatus(
            path: .init(memberId: Int64(userIdInt))
        )

        switch response {
        case .ok:
            // 성공
            return
        default:
            if case .undocumented(let statusCode, let payload) = response {
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let responseBody = String(data: data, encoding: .utf8) {
                        #if DEBUG
                        print("[Setting] unblock error [\(statusCode)]: \(responseBody)")
                        #endif
                    }
                }
            }
            throw SettingError.networkError
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
}
