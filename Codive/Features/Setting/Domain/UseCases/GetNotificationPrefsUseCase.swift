//
//  SettingUseCase.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//
import Foundation

// MARK: - GetNotificationPrefsUseCase
final class GetNotificationPrefsUseCase {

    // MARK: - Properties
    private let repository: SettingRepository

    // MARK: - Initializer
    init(repository: SettingRepository) {
        self.repository = repository
    }

    // MARK: - Execute
    /// 현재 알림 설정 조회
    func fetch() async throws -> NotificationPrefs {
        try await repository.getNotificationPrefs()
    }
}
