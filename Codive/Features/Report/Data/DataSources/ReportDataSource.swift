//
//  ReportDataSource.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//

import Foundation

final class ReportDataSource {

    // 일단 더미 reportId 반환
    func submit(_ report: Report) async throws -> String? {
        return UUID().uuidString
    }

    // 신고 컨텍스트 조회 일단 더미 데이터 반환
    func fetchContext(for target: ReportTarget) async throws -> ReportContext {
        let author = AuthorSnapshot(
            userId: 42,
            nickname: "신고작성자",
            handle: "report_user",
            avatarURL: nil
        )

        let preview: String
        switch target {
        case .post(let id):    preview = "게시글 #\(id)의 미리보기 텍스트"
        case .comment(let id): preview = "댓글 #\(id)의 미리보기 텍스트"
        }

        return ReportContext(target: target, author: author, previewText: preview)
    }
}
