//
//  ReportRepositoryImpl.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//

import Foundation

// ReportRepositoryImpl이 아래 3개 프로토콜을 모두 준수하도록 만든다.
final class ReportRepositoryImpl:
    ReportRepository,
    ReportContextProvider {

    private let dataSource: ReportDataSource

    init(dataSource: ReportDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - ReportSubmitProvider
    func submit(_ report: Report) async throws -> String? {
        return try await dataSource.submit(report)
    }

    // MARK: - ReportContextProvider
    func fetchContext(for target: ReportTarget) async throws -> ReportContext {
        return try await dataSource.fetchContext(for: target)
    }
}
