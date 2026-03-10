//
//  CheckTodayRecordUseCaseTests.swift
//  CodiveTests
//

import Foundation
import Testing
@testable import Codive

struct CheckTodayRecordUseCaseTests {

    // MARK: - Test: 오늘 기록이 존재하면 true 반환

    @Test("오늘 기록이 존재하면 true를 반환한다")
    func returnsTrueWhenTodayRecordExists() async {
        let todayString = DateFormatter.yyyyMMdd.string(from: Date())
        let mockRepository = MockHistoryRepository(items: [
            MonthlyHistoryItem(historyId: 1, firstImageUrl: "https://example.com/1.jpg", historyDate: todayString)
        ])
        let useCase = CheckTodayRecordUseCase(
            historyRepository: mockRepository,
            memberIdProvider: { 1 }
        )

        let result = await useCase.execute()
        #expect(result == true)
    }

    // MARK: - Test: 오늘 기록이 없으면 false 반환

    @Test("오늘 기록이 없으면 false를 반환한다")
    func returnsFalseWhenNoTodayRecord() async {
        let mockRepository = MockHistoryRepository(items: [
            MonthlyHistoryItem(historyId: 1, firstImageUrl: "https://example.com/1.jpg", historyDate: "2020-01-01")
        ])
        let useCase = CheckTodayRecordUseCase(
            historyRepository: mockRepository,
            memberIdProvider: { 1 }
        )

        let result = await useCase.execute()
        #expect(result == false)
    }

    // MARK: - Test: memberId가 nil이면 false 반환

    @Test("memberId가 nil이면 false를 반환한다")
    func returnsFalseWhenMemberIdIsNil() async {
        let mockRepository = MockHistoryRepository(items: [])
        let useCase = CheckTodayRecordUseCase(
            historyRepository: mockRepository,
            memberIdProvider: { nil }
        )

        let result = await useCase.execute()
        #expect(result == false)
    }

    // MARK: - Test: API 에러 발생 시 false 반환

    @Test("API 에러 발생 시 false를 반환한다")
    func returnsFalseOnAPIError() async {
        let mockRepository = MockHistoryRepositoryWithError()
        let useCase = CheckTodayRecordUseCase(
            historyRepository: mockRepository,
            memberIdProvider: { 1 }
        )

        let result = await useCase.execute()
        #expect(result == false)
    }
}

// MARK: - Mock HistoryRepository

private final class MockHistoryRepository: HistoryRepository {
    private let items: [MonthlyHistoryItem]

    init(items: [MonthlyHistoryItem]) {
        self.items = items
    }

    func fetchMonthlyHistory(memberId: Int64, year: Int32, month: Int32) async throws -> [MonthlyHistoryItem] {
        items
    }

    func deleteHistory(historyId: Int64) async throws {}
}

private final class MockHistoryRepositoryWithError: HistoryRepository {
    func fetchMonthlyHistory(memberId: Int64, year: Int32, month: Int32) async throws -> [MonthlyHistoryItem] {
        throw NSError(domain: "TestError", code: -1)
    }

    func deleteHistory(historyId: Int64) async throws {}
}

// MARK: - DateFormatter Helper

private extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
