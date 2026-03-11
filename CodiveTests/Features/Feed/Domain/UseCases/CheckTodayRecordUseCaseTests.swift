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
        let mockRepository = MockHistoryRepository(todayExists: true)
        let useCase = CheckTodayRecordUseCase(historyRepository: mockRepository)

        let result = await useCase.execute()
        #expect(result == true)
    }

    // MARK: - Test: 오늘 기록이 없으면 false 반환

    @Test("오늘 기록이 없으면 false를 반환한다")
    func returnsFalseWhenNoTodayRecord() async {
        let mockRepository = MockHistoryRepository(todayExists: false)
        let useCase = CheckTodayRecordUseCase(historyRepository: mockRepository)

        let result = await useCase.execute()
        #expect(result == false)
    }

    // MARK: - Test: API 에러 발생 시 false 반환

    @Test("API 에러 발생 시 false를 반환한다")
    func returnsFalseOnAPIError() async {
        let mockRepository = MockHistoryRepositoryWithError()
        let useCase = CheckTodayRecordUseCase(historyRepository: mockRepository)

        let result = await useCase.execute()
        #expect(result == false)
    }
}

// MARK: - Mock HistoryRepository

private final class MockHistoryRepository: HistoryRepository {
    private let todayExists: Bool

    init(todayExists: Bool) {
        self.todayExists = todayExists
    }

    func fetchMonthlyHistory(memberId: Int64, year: Int32, month: Int32) async throws -> [MonthlyHistoryItem] {
        []
    }

    func checkTodayHistoryExists() async throws -> Bool {
        todayExists
    }

    func deleteHistory(historyId: Int64) async throws {}
}

private final class MockHistoryRepositoryWithError: HistoryRepository {
    func fetchMonthlyHistory(memberId: Int64, year: Int32, month: Int32) async throws -> [MonthlyHistoryItem] {
        throw NSError(domain: "TestError", code: -1)
    }

    func checkTodayHistoryExists() async throws -> Bool {
        throw NSError(domain: "TestError", code: -1)
    }

    func deleteHistory(historyId: Int64) async throws {}
}
