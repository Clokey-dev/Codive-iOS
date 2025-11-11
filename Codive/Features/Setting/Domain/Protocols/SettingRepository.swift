//
//  SettingRepository.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//

import Foundation

public protocol SettingRepository {
    // 좋아요한 기록 가져오기
    func fetchLikedRecords(page: Int, pageSize: Int) async throws -> [LikedRecord]

    // 내가 남긴 댓글 가져오기
    func fetchMyComments(page: Int, pageSize: Int) async throws -> [MyComment]

    // 차단한 계정 가져오기
    func fetchBlockedUsers() async throws -> [BlockedUser]
    func unblock(userId: UserID) async throws

    // 알림 설정
    func getNotificationPrefs() async throws -> NotificationPrefs
    func updateNotificationPrefs(_ prefs: NotificationPrefs) async throws

    // 계정 탈퇴
    func getWithdrawNotices() async throws -> [WithdrawNotice] // 탈퇴 전 화면 제공
    func withdrawAccount() async throws //탈퇴처리
}
