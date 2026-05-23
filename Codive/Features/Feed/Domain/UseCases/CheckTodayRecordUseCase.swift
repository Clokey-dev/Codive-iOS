//
//  CheckTodayRecordUseCase.swift
//  Codive
//

import Foundation

final class CheckTodayRecordUseCase {
    private let historyRepository: HistoryRepository

    init(historyRepository: HistoryRepository) {
        self.historyRepository = historyRepository
    }

    /// 오늘 날짜에 이미 기록이 존재하는지 확인
    func execute() async -> Bool {
        do {
            return try await historyRepository.checkTodayHistoryExists()
        } catch {
            #if DEBUG
            print("[CheckTodayRecord] 오늘 기록 확인 실패: \(error)")
            #endif
            return false
        }
    }
}
