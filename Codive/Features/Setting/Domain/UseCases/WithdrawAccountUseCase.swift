//
//  SettingUseCase.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//
import Foundation

// MARK: - WithdrawAccountUseCase
final class WithdrawAccountUseCase {

    // MARK: - Properties
    private let authRepository: AuthRepository

    // MARK: - Initializer
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    // MARK: - Execute
    /// 계정 비활성화 (15일 뒤 자동 탈퇴)
    func execute() async throws {
        try await authRepository.deactivateAccount()
    }
}
