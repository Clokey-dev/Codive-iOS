//
//  SettingUseCase.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//
import Foundation

// MARK: -  UpdateNotificationPrefsUseCase
final class  UpdateNotificationPrefsUseCase {

    // MARK: - Properties
    private let repository: SettingRepository

    // MARK: - Initializer
    init(repository: SettingRepository) {
        self.repository = repository
    }
    
    // MARK: - Execute
    /// 알림 설정 업데이트
    func update(_ prefs: NotificationPrefs) async throws {
        try await repository.updateNotificationPrefs(prefs)
    }
}
