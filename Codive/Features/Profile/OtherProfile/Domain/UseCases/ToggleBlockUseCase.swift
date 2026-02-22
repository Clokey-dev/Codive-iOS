//
//  ToggleBlockUseCase.swift
//  Codive
//
//  Created by 황상환 on 2026-02-12.
//

import Foundation

public protocol ToggleBlockUseCase {
    func execute(memberId: Int) async throws
}

final class DefaultToggleBlockUseCase: ToggleBlockUseCase {
    private let repository: OtherProfileRepository

    init(repository: OtherProfileRepository) {
        self.repository = repository
    }

    func execute(memberId: Int) async throws {
        try await repository.toggleBlock(memberId: memberId)
    }
}
