//
//  SettingUseCase.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//
import Foundation

// MARK: - UnblockUserUseCase
final class UnblockUserUseCase {

    // MARK: - Properties
    private let repository: SettingRepository

    // MARK: - Initializer
    init(repository: SettingRepository) {
        self.repository = repository
    }

    // MARK: - Execute
    /// 특정 사용자를 차단 해제
    func execute(userId: UserID) async throws {
        try await repository.unblock(userId: userId)
    }
}
