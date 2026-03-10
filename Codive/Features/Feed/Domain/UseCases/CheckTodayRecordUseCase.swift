//
//  CheckTodayRecordUseCase.swift
//  Codive
//

import Foundation

final class CheckTodayRecordUseCase {
    private let historyRepository: HistoryRepository
    private let memberIdProvider: () -> Int?

    init(
        historyRepository: HistoryRepository,
        memberIdProvider: @escaping () -> Int?
    ) {
        self.historyRepository = historyRepository
        self.memberIdProvider = memberIdProvider
    }

    /// 오늘 날짜에 이미 기록이 존재하는지 확인
    func execute() async -> Bool {
        guard let userId = memberIdProvider() else { return false }

        let now = Date()
        let calendar = Calendar.current
        let year = Int32(calendar.component(.year, from: now))
        let month = Int32(calendar.component(.month, from: now))

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: now)

        do {
            let histories = try await historyRepository.fetchMonthlyHistory(
                memberId: Int64(userId),
                year: year,
                month: month
            )
            return histories.contains { $0.historyDate == todayString }
        } catch {
            #if DEBUG
            print("[CheckTodayRecord] 월간 기록 조회 실패: \(error)")
            #endif
            return false
        }
    }
}
