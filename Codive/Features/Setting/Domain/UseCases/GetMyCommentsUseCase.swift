//
//  SettingUseCase.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//
import Foundation

// MARK: - GetMyCommentsUseCase
final class GetMyCommentsUseCase {

    // MARK: - Properties
    private let repository: SettingRepository

    // MARK: - Initializer
    init(repository: SettingRepository) {
        self.repository = repository
    }

    // MARK: - Execute
    /// 내가 남긴 댓글을 페이지로 조회
    func fetch(page: Int = 1, size: Int = 20) async throws -> [MyComment] {
        try await repository.fetchMyComments(page: page, pageSize: size)
    }
}
