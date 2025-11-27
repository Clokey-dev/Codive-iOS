//
//  SettingsRepositoryImpl.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//
import Foundation

final class SettingsRepositoryImpl: SettingRepository {

    // MARK: Properties
    private let dataSource: SettingsDataSource

    // MARK: Init
    init(dataSource: SettingsDataSource) {
        self.dataSource = dataSource
    }

    // MARK: Liked records
    func fetchLikedRecords(page: Int, pageSize: Int) async throws -> [LikedRecord] {
        try await dataSource.fetchLikedRecords(page: page, pageSize: pageSize)
    }

    // MARK: My comments
    func fetchMyComments(page: Int, pageSize: Int) async throws -> [MyComment] {
        try await dataSource.fetchMyComments(page: page, pageSize: pageSize)
    }

    // MARK: Blocked users
    func fetchBlockedUsers() async throws -> [BlockedUser] {
        try await dataSource.fetchBlockedUsers()
    }

    func unblock(userId: UserID) async throws {
        try await dataSource.unblock(userId: userId)
    }

    // MARK: Notification prefs
    func getNotificationPrefs() async throws -> NotificationPrefs {
        try await dataSource.getNotificationPrefs()
    }

    func updateNotificationPrefs(_ prefs: NotificationPrefs) async throws {
        try await dataSource.updateNotificationPrefs(prefs)
    }

    // MARK: Withdraw
    func getWithdrawNotices() async throws -> [WithdrawNotice] {
        try await dataSource.getWithdrawNotices()
    }

    func withdrawAccount() async throws {
        try await dataSource.withdrawAccount()
    }
}
