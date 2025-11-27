//
//  SettingUseCase.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//
import Foundation

    // MARK: - GetBlockedUsersUseCase
final class  GetBlockedUsersUseCase {

    // MARK: - Properties
    private let repository: SettingRepository

    // MARK: - Initializer
    init(repository: SettingRepository) {
        self.repository = repository
    }

    // MARK: - Execute
    /// 차단한 사용자 목록 조회
    func fetchAll() async throws -> [BlockedUser] {
        try await repository.fetchBlockedUsers()
    }
}
