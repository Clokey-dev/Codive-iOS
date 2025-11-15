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
    @Published var context: ReportContext?          // 작성자/미리보기
    @Published var isLoading: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?

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
        objectWillChange.send()
    }
    func updateDetail(_ text: String) {
        draft.updateDetail(text)
        objectWillChange.send()
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
            self.errorMessage = "신고 대상을 불러오지 못했습니다."
        }
        isLoading = false
    }

    // 제출
    @discardableResult
    func submit(reporterId: UserID) async -> String? {
        guard !isSubmitting else { return nil }
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let id = try await submitUseCase.submit(draft: draft, reporterId: reporterId)
            return id
        } catch let ReportError.invalidDraft(failure) {
            switch failure {
            case .missingReason:
                errorMessage = "신고 사유를 선택해 주세요."
            case .detailRequiredForEtc:
                errorMessage = "기타 사유를 입력해 주세요."
            case .detailTooLong(let limit):
                errorMessage = "상세 내용은 \(limit)자 이내로 입력해 주세요."
            }
            return nil
        } catch {
            errorMessage = "신고 제출에 실패했습니다. 잠시 후 다시 시도해 주세요."
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
}
