//
//  DeleteHistoryUseCase.swift
//  Codive
//
//  Created by Claude on 2026-02-12.
//

import Foundation

protocol DeleteHistoryUseCase {
    func execute(historyId: Int64) async throws
}

final class DefaultDeleteHistoryUseCase: DeleteHistoryUseCase {
    private let repository: HistoryRepository

    init(repository: HistoryRepository) {
        self.repository = repository
    }

    func execute(historyId: Int64) async throws {
        try await repository.deleteHistory(historyId: historyId)
    }
}
