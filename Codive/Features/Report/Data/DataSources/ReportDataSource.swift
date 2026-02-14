//
//  ReportDataSource.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//

import Foundation
import CodiveAPI

// MARK: - 신고 API 에러
enum ReportSubmitError: Error {
    case duplicateReport(message: String)
    case serverError(message: String)
}

// MARK: - 댓글 신고 시 컨텍스트 전달용 임시 저장소
struct CommentReportInfo {
    let feedId: Int
    let commentId: Int
    let authorNickname: String
    let authorProfileImageUrl: String?
    let content: String
    let authorId: Int
}

final class ReportDataSource {

    // 댓글 신고 시 CommentViewModel에서 세팅
    static var pendingCommentReportInfo: CommentReportInfo?

    private let historyAPIService: HistoryAPIServiceProtocol
    private let apiClient: Client

    init(historyAPIService: HistoryAPIServiceProtocol) {
        self.historyAPIService = historyAPIService
        self.apiClient = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: KeychainTokenProvider())]
        )
    }

    func submit(_ report: Report) async throws -> String? {
        let targetId: Int64
        let targetType: Components.Schemas.ReportCreateRequest.targetTypePayload
        let reportReason: Components.Schemas.ReportCreateRequest.reportReasonPayload

        switch report.target {
        case .post(let id):
            targetId = Int64(id)
            targetType = .HISTORY
        case .comment(let id):
            targetId = Int64(id)
            targetType = .COMMENT
        }

        switch report.reason {
        case .comment(let reason):
            switch reason {
            case .abuse:   reportReason = .SWEARING_AND_CURSING
            case .discrim: reportReason = .DISCRIMINATORY_AND_HATEFUL
            case .spam:    reportReason = .SPAM_OR_PROMOTION
            case .privacy: reportReason = .PRIVATE_INFO
            case .hate:    reportReason = .ANNOYING_COMMENT
            case .etc:     reportReason = .ETC_COMMENT
            }
        case .post(let reason):
            switch reason {
            case .sexual:   reportReason = .SEXUAL
            case .violence: reportReason = .VIOLENT
            case .harmful:  reportReason = .HARMFUL_TO_MINORS
            case .privacy:  reportReason = .PRIVACY_EXPOSURE
            case .hate:     reportReason = .ANNOYING_HISTORY
            case .etc:      reportReason = .ETC_HISTORY
            }
        }

        let body = Components.Schemas.ReportCreateRequest(
            targetId: targetId,
            targetType: targetType,
            reportReason: reportReason,
            content: report.detail
        )

        print("📡 [ReportAPI] 요청 - targetId: \(targetId), targetType: \(targetType), reason: \(reportReason), detail: \(report.detail ?? "없음")")

        let response = try await apiClient.Report_createNewReport(
            body: .json(body)
        )

        switch response {
        case .ok(let okResponse):
            print("📡 [ReportAPI] 응답: OK")
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)
            print("📡 [ReportAPI] 응답 데이터: \(String(data: data, encoding: .utf8) ?? "파싱 불가")")
            let jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
            let apiResponse = try jsonDecoder.decode(
                Components.Schemas.BaseResponseReportCreateResponse.self,
                from: data
            )
            if let reportId = apiResponse.result?.reportId {
                print("📡 [ReportAPI] reportId: \(reportId)")
                return String(reportId)
            }
            print("⚠️ [ReportAPI] 응답 OK이지만 reportId가 nil")
            return nil
        case .undocumented(statusCode: let statusCode, let payload):
            if let body = payload.body {
                let data = try await Data(collecting: body, upTo: .max)
                let bodyString = String(data: data, encoding: .utf8) ?? "파싱 불가"
                print("❌ [ReportAPI] 실패 응답 (\(statusCode)): \(bodyString)")

                // JSON 파싱하여 서버 에러 코드 확인
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let code = json["code"] as? String,
                   let message = json["message"] as? String {
                    if code == "REPORT_4001" {
                        throw ReportSubmitError.duplicateReport(message: message)
                    }
                    throw ReportSubmitError.serverError(message: message)
                }

                throw NSError(domain: "ReportDataSource", code: statusCode, userInfo: [NSLocalizedDescriptionKey: bodyString])
            }
            print("❌ [ReportAPI] 실패 응답 (\(statusCode)): 본문 없음")
            throw NSError(domain: "ReportDataSource", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to submit report (status: \(statusCode))"])
        }
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

        case .comment:
            if let info = ReportDataSource.pendingCommentReportInfo {
                let author = AuthorSnapshot(
                    userId: info.authorId,
                    nickname: info.authorNickname,
                    handle: "",
                    avatarURL: info.authorProfileImageUrl.flatMap { URL(string: $0) }
                )
                return ReportContext(target: target, author: author, previewText: info.content)
            }
            let author = AuthorSnapshot(
                userId: 0,
                nickname: "댓글작성자",
                handle: "",
                avatarURL: nil
            )
            return ReportContext(target: target, author: author, previewText: "")
        }
    }
}
