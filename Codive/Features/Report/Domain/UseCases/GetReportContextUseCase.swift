//
//  GetReportContextUseCase.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//

import Foundation

// 신고 화면 상단에 보여줄 작성자/본문 미리보기 조회
final class GetReportContextUseCase {
    
    // 의존성
    private let provider: ReportContextProvider
    
    // 생성자
    init(provider: ReportContextProvider) {
        self.provider = provider
    }
    
    // 대상별 컨텍스트 단건 조회
    func fetchContext(for target: ReportTarget) async throws -> ReportContext {
        try await provider.fetchContext(for: target)
    }
}
