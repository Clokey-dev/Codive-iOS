//
//  HistoryRepository.swift
//  Codive
//
//  Created by Claude Code on 1/31/26.
//

import Foundation

protocol HistoryRepository {
    func fetchMonthlyHistory(memberId: Int64, year: Int32, month: Int32) async throws -> [MonthlyHistoryItem]
}
