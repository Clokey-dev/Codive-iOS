//
//  ReportDataSource.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - 신고 API 에러
enum ReportSubmitError: Error {
    case duplicateReport(message: String)
    case serverError(message: String)
}

// MARK: - 댓글 신고 시 컨텍스트 전달용 임시 저장소
struct CommentReportInfo: Hashable {
    let feedId: Int
    let commentId: Int
    let authorNickname: String
    let authorProfileImageUrl: String?
    let content: String
    let authorId: Int
}

final class ReportDataSource {

    private let historyAPIService: HistoryAPIServiceProtocol
    private let apiClient: Client

    init(historyAPIService: HistoryAPIServiceProtocol) {
        self.historyAPIService = historyAPIService
        self.apiClient = CodiveAPIProvider.createConfiguredClient(
            middlewares: [CodiveAuthMiddleware(provider: KeychainTokenProvider())]
        )
    }

    func submit(_ report: Report) async throws -> String? {
        let (targetId, targetType) = mapTarget(report.target)
        let reportReason = mapReason(report.reason)

        let body = Components.Schemas.ReportCreateRequest(
            targetId: targetId,
            targetType: targetType,
            reportReason: reportReason,
            content: report.detail
        )

        #if DEBUG
        print("[ReportAPI] 요청 - targetId: \(targetId), targetType: \(targetType), reason: \(reportReason), detail: \(report.detail ?? "없음")")
        #endif

        let response = try await apiClient.Report_createNewReport(body: .json(body))

        switch response {
        case .ok(let okResponse):
            return try await parseOkResponse(okResponse)
        case .undocumented(statusCode: let statusCode, let payload):
            return try await handleUndocumentedResponse(statusCode: statusCode, payload: payload)
        }
    }

    // MARK: - Private Helpers

    private func mapTarget(
        _ target: ReportTarget
    ) -> (Int64, Components.Schemas.ReportCreateRequest.targetTypePayload) {
        switch target {
        case .post(let id): return (Int64(id), .HISTORY)
        case .comment(let id): return (Int64(id), .COMMENT)
        }
    }

    private func mapReason(
        _ reason: ReportReason
    ) -> Components.Schemas.ReportCreateRequest.reportReasonPayload {
        switch reason {
        case .comment(let r):
            switch r {
            case .abuse:   return .SWEARING_AND_CURSING
            case .discrim: return .DISCRIMINATORY_AND_HATEFUL
            case .spam:    return .SPAM_OR_PROMOTION
            case .privacy: return .PRIVATE_INFO
            case .hate:    return .ANNOYING_COMMENT
            case .etc:     return .ETC_COMMENT
            }
        case .post(let r):
            switch r {
            case .sexual:   return .SEXUAL
            case .violence: return .VIOLENT
            case .harmful:  return .HARMFUL_TO_MINORS
            case .privacy:  return .PRIVACY_EXPOSURE
            case .hate:     return .ANNOYING_HISTORY
            case .etc:      return .ETC_HISTORY
            }
        }
    }

    private func parseOkResponse(
        _ okResponse: Operations.Report_createNewReport.Output.Ok
    ) async throws -> String? {
        #if DEBUG
        print("[ReportAPI] 응답: OK")
        #endif
        let apiResponse = try okResponse.body.json
        if let reportId = apiResponse.result?.reportId {
            #if DEBUG
            print("[ReportAPI] reportId: \(reportId)")
            #endif
            return String(reportId)
        }
        #if DEBUG
        print("[ReportAPI] 응답 OK이지만 reportId가 nil")
        #endif
        return nil
    }

    private func handleUndocumentedResponse(
        statusCode: Int, payload: UndocumentedPayload
    ) async throws -> String? {
        if let body = payload.body {
            let data = try await Data(collecting: body, upTo: .max)
            let bodyString = String(data: data, encoding: .utf8) ?? "파싱 불가"
            #if DEBUG
            print("[ReportAPI] 실패 응답 (\(statusCode)): \(bodyString)")
            #endif

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
        #if DEBUG
        print("[ReportAPI] 실패 응답 (\(statusCode)): 본문 없음")
        #endif
        throw NSError(domain: "ReportDataSource", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to submit report (status: \(statusCode))"])
    }

    // 신고 컨텍스트 조회 - 실제 History API에서 데이터 가져오기
    func fetchContext(for target: ReportTarget, commentInfo: CommentReportInfo? = nil) async throws -> ReportContext {
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
            if let info = commentInfo {
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
