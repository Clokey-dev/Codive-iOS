//
//  ReportRepository.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//

import Foundation

// MARK: - ReportRepository
// 신고를 서버에 제출
protocol ReportRepository {
    func submit(_ report: Report) async throws -> String?
}

// 신고 화면에 신고 대상의 프로필과 내용을 가져오기 위함
protocol ReportContextProvider {
    func fetchContext(for target: ReportTarget) async throws -> ReportContext
}
