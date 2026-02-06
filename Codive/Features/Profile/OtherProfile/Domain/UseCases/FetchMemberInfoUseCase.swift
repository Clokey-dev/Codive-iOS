//
//  FetchMemberInfoUseCase.swift
//  Codive
//
//  Created by 황상환 on 2026-02-05.
//

import Foundation

public protocol FetchMemberInfoUseCase {
    func execute(memberId: Int) async throws -> OtherProfileEntity
}

final class DefaultFetchMemberInfoUseCase: FetchMemberInfoUseCase {
    private let repository: OtherProfileRepository

    init(repository: OtherProfileRepository) {
        self.repository = repository
    }

    func execute(memberId: Int) async throws -> OtherProfileEntity {
        return try await repository.fetchMemberInfo(memberId: memberId)
    }
}
