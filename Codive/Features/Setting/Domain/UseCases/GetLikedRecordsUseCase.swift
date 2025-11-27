//
//  SettingUseCase.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//
import Foundation

// MARK: - GetLikedRecordsUseCase
final class GetLikedRecordsUseCase {

    // MARK: - Properties
    private let repository: SettingRepository

    // MARK: - Initializer
    init(repository: SettingRepository) {
        self.repository = repository
    }

    // MARK: - Execute
    /// 내가 좋아요한 기록을 페이지로 조회
    func fetch(page: Int = 1, size: Int = 20) async throws -> [LikedRecord] {
        try await repository.fetchLikedRecords(page: page, pageSize: size)
    }
}
