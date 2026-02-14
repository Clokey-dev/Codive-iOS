//
//  ReportPopupViewModel.swift
//  Codive
//
//  Created by 한태빈 on 10/14/25.
//

import SwiftUI

@MainActor
final class ReportViewModel: ObservableObject {
    // 의존성
    private let appRouter: AppRouter
    private let navigationRouter: NavigationRouter
    private let getContextUseCase: GetReportContextUseCase
    private let submitUseCase: SubmitReportUseCase

    // 대상
    let target: ReportTarget

    // 화면 상태
    @Published private(set) var draft: ReportDraft
    @Published var context: ReportContext?        
    @Published var isLoading: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    @Published var showDuplicateAlert: Bool = false
    @Published var duplicateAlertMessage: String = ""

    // 초기화
    init(target: ReportTarget,
         appRouter: AppRouter,
         navigationRouter: NavigationRouter,
         getContextUseCase: GetReportContextUseCase,
         submitUseCase: SubmitReportUseCase) {
        self.target = target
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
        self.getContextUseCase = getContextUseCase
        self.submitUseCase = submitUseCase
        self.draft = ReportDraft(target: target)
    }

    // 표시용 타이틀
    var navTitle: String {
        switch target {
        case .post:    return "기록 신고하기"
        case .comment: return "댓글 신고하기"
        }
    }
    var contentSectionTitle: String {
        switch target {
        case .post:    return "기록 내용"
        case .comment: return "댓글 내용"
        }
    }

    // 대상별 사유 리스트
    var reasonList: [ReportReason] {
        switch target {
        case .post:    return PostReportReason.allCases.map { .post($0) }
        case .comment: return CommentReportReason.allCases.map { .comment($0) }
        }
    }

    // 선택/입력 액션
    func select(reason: ReportReason) {
        draft.select(reason)
    }
    func updateDetail(_ text: String) {
        draft.updateDetail(text)
    }

    // 버튼 활성화
    var isNextEnabled: Bool {
        draft.validate().isValid
    }

    // 컨텍스트 로드
    func loadContext() async {
        isLoading = true
        errorMessage = nil
        do {
            let ctx = try await getContextUseCase.fetchContext(for: target)
            self.context = ctx
        } catch {
            self.errorMessage = TextLiteral.Report.loadContextFailure
        }
        isLoading = false
    }

    // 제출
    @discardableResult
    func submit(reporterId: ReporterID) async -> String? {
        guard !isSubmitting else {
            print("⚠️ [Report] 이미 제출 중 - 중복 호출 무시")
            return nil
        }
        isSubmitting = true
        defer { isSubmitting = false }

        print("📤 [Report] 제출 시작 - reporterId: \(reporterId), target: \(target), reason: \(String(describing: draft.selectedReason))")

        do {
            let id = try await submitUseCase.submit(draft: draft, reporterId: reporterId)
            print("✅ [Report] 제출 성공 - reportId: \(String(describing: id))")
            return id
        } catch let ReportError.invalidDraft(failure) {
            print("❌ [Report] 유효성 검사 실패: \(failure)")
            switch failure {
            case .missingReason:
                errorMessage = TextLiteral.Report.selectReason
            case .detailTooLong(let limit):
                errorMessage = TextLiteral.Report.detailTooLong(limit)
            case .detailRequiredForEtc:
                break
            }
            return nil
        } catch let ReportSubmitError.duplicateReport(message) {
            print("⚠️ [Report] 중복 신고: \(message)")
            duplicateAlertMessage = message
            showDuplicateAlert = true
            return nil
        } catch {
            print("❌ [Report] 제출 실패: \(error)")
            errorMessage = TextLiteral.Report.submitFailure
            return nil
        }
    }

    // View 바인딩용
    var selectedReason: ReportReason? { draft.selectedReason }
    var draftDetail: String { draft.detail }

    // UI 표기용 (placeholder 포함)
    var authorName: String { context?.author.nickname ?? "닉네임" }
    var authorHandle: String { context?.author.handle ?? "아이디" }
    var contentPreview: String { context?.previewText ?? "" }

    // 상태 리셋
    func reset() {
        draft = ReportDraft(target: target)
    }
}
