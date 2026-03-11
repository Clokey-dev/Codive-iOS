//
//  HistoryRepository.swift
//  Codive
//
//  Created by 황상환 on 1/31/26.
//

import Foundation

protocol HistoryRepository {
    func fetchMonthlyHistory(memberId: Int64, year: Int32, month: Int32) async throws -> [MonthlyHistoryItem]
    func checkTodayHistoryExists() async throws -> Bool
    func deleteHistory(historyId: Int64) async throws
}
