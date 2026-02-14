//
//  ReportDataSource.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//

import Foundation

final class ReportDataSource {

    private let historyAPIService: HistoryAPIServiceProtocol

    init(historyAPIService: HistoryAPIServiceProtocol) {
        self.historyAPIService = historyAPIService
    }

    // 일단 더미 reportId 반환
    func submit(_ report: Report) async throws -> String? {
        return UUID().uuidString
    }

    // 신고 컨텍스트 조회 - 실제 History API에서 데이터 가져오기
    func fetchContext(for target: ReportTarget) async throws -> ReportContext {
        switch target {
        case .post(let postId):
            // History ID로 상세 정보 조회
            let historyDetail = try await historyAPIService.fetchHistoryDetail(historyId: Int64(postId))

            // HistoryDetailDTO -> AuthorSnapshot 변환
            let author = AuthorSnapshot(
                userId: Int(historyDetail.memberId),
                nickname: historyDetail.nickname ?? "작성자",
                handle: "",  // handle은 API에서 제공하지 않음
                avatarURL: historyDetail.profileImageUrl.flatMap { URL(string: $0) }
            )

            // previewText는 content 사용
            let previewText = historyDetail.content ?? ""

            return ReportContext(target: target, author: author, previewText: previewText)

        case .comment(let commentId):
            // 댓글 신고는 아직 미구현
            let author = AuthorSnapshot(
                userId: 0,
                nickname: "댓글작성자",
                handle: "",
                avatarURL: nil
            )
            return ReportContext(target: target, author: author, previewText: "댓글 내용")
        }
    }
}
