//
//  SettingUseCase.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//
import Foundation

// MARK: - GetWithdrawNoticesUseCase
final class GetWithdrawNoticesUseCase {

    // MARK: - Properties
    private let repository: SettingRepository

    // MARK: - Initializer
    init(repository: SettingRepository) {
        self.repository = repository
    }

    // MARK: - Execute
    /// 계정 탈퇴 안내 카드(문구 리스트) 조회
    func fetch() async throws -> [WithdrawNotice] {
        try await repository.getWithdrawNotices()
    }
}
