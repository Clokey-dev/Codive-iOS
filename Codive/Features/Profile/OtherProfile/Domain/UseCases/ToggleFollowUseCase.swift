//
//  ToggleFollowUseCase.swift
//  Codive
//
//  Created by 황상환 on 2026-02-05.
//

import Foundation

public protocol ToggleFollowUseCase {
    func execute(memberId: Int, isPublic: Bool) async throws
}

final class DefaultToggleFollowUseCase: ToggleFollowUseCase {
    private let repository: OtherProfileRepository

    init(repository: OtherProfileRepository) {
        self.repository = repository
    }

    func execute(memberId: Int, isPublic: Bool) async throws {
        try await repository.toggleFollow(memberId: memberId, isPublic: isPublic)
    }
}
