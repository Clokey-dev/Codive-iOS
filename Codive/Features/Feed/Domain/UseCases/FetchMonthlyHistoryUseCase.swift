//
//  FetchMonthlyHistoryUseCase.swift
//  Codive
//
//  Created by 황상환 on 1/31/26.
//

import Foundation

final class FetchMonthlyHistoryUseCase {
    private let historyRepository: HistoryRepository

    init(historyRepository: HistoryRepository) {
        self.historyRepository = historyRepository
    }

    func execute(memberId: Int64, year: Int32, month: Int32) async throws -> [MonthlyHistoryItem] {
        try await historyRepository.fetchMonthlyHistory(memberId: memberId, year: year, month: month)
    }
}
