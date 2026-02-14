//
//  SubmitReportUseCase.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//

import Foundation

// 신고 제출 유스케이스
final class SubmitReportUseCase {

    // 의존성
    private let repository: ReportRepository

    // 생성자
    init(repository: ReportRepository) {
        self.repository = repository
    }

    // 현재 초안이 유효한지 빠르게 확인할 때 사용 (VM에서 버튼 활성 조건 등에 활용)
    func validate(_ draft: ReportDraft) -> ReportValidation {
        draft.validate()
    }

    // 신고 제출: 검증 → Report 빌드 → 저장소 위임
    @discardableResult
    func submit(draft: ReportDraft, reporterId: ReporterID) async throws -> String? {
        let result = draft.validate()
        guard result.isValid else {
            // 도메인 규칙 위반은 그대로 throw
            throw ReportError.invalidDraft(result.failure!)
        }
        let report = try draft.build(reporterId: reporterId)
        return try await repository.submit(report)
    }
}
