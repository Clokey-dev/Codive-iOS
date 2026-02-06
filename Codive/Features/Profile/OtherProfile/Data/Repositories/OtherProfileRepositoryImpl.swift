//
//  OtherProfileRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 2026-02-05.
//

import Foundation

final class OtherProfileRepositoryImpl: OtherProfileRepository {
    private let apiService: ProfileAPIServiceProtocol

    init(apiService: ProfileAPIServiceProtocol) {
        self.apiService = apiService
    }

    func fetchMemberInfo(memberId: Int) async throws -> OtherProfileEntity {
        return try await apiService.fetchMemberInfo(memberId: memberId)
    }

    func toggleFollow(memberId: Int, isPublic: Bool) async throws {
        if isPublic {
            try await apiService.toggleFollow(memberId: memberId)
        } else {
            try await apiService.togglePendingFollow(memberId: memberId)
        }
    }

    func toggleBlock(memberId: Int) async throws {
        // 차단 API는 나중에 구현
        print("차단 기능은 추후 구현")
    }
}
