import Foundation
import SwiftUI

@MainActor
final class ReportDIContainer {

    // MARK: - Dependencies
    private let appRouter: AppRouter
    private let navigationRouter: NavigationRouter
    private let tokenService: TokenServiceProtocol

    // ViewFactory
    lazy var reportViewFactory = ReportViewFactory(reportDIContainer: self)

    // MARK: - Data / Repository
    private let repository: any ReportRepository
    private let contextProvider: any ReportContextProvider

    // MARK: - Current Report ViewModel (신고 플로우 진행 중에만 유지)
    private var currentReportViewModel: (target: ReportTarget, viewModel: ReportViewModel)?

    // 신고 플로우 종료 시 호출
    func clearCurrentReport() {
        currentReportViewModel = nil
    }

    // MARK: - Init
    init(
        appRouter: AppRouter,
        navigationRouter: NavigationRouter,
        tokenService: TokenServiceProtocol = TokenService()
    ) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
        self.tokenService = tokenService

        // HistoryAPIService 생성
        let historyAPIService = HistoryAPIService()

        let dataSource = ReportDataSource(historyAPIService: historyAPIService)
        let repoImpl = ReportRepositoryImpl(dataSource: dataSource)

        self.repository = repoImpl
        self.contextProvider = repoImpl
    }
    
    // MARK: - UseCases
    func makeGetReportContextUseCase() -> GetReportContextUseCase {
        GetReportContextUseCase(provider: contextProvider)
    }
    
    func makeSubmitReportUseCase() -> SubmitReportUseCase {
        SubmitReportUseCase(repository: repository)
    }
    
    // MARK: - ViewModels
    func makeReportViewModel(target: ReportTarget, commentInfo: CommentReportInfo? = nil) -> ReportViewModel {
        // 같은 target의 현재 진행중인 신고가 있으면 재사용 (ReportView → ReportDetailView 이동 시)
        if let current = currentReportViewModel, current.target == target {
            return current.viewModel
        }

        // 새로운 신고 플로우 시작
        let vm = ReportViewModel(
            target: target,
            commentInfo: commentInfo,
            appRouter: appRouter,
            navigationRouter: navigationRouter,
            getContextUseCase: makeGetReportContextUseCase(),
            submitUseCase: makeSubmitReportUseCase()
        )

        // 현재 진행중인 신고로 저장
        currentReportViewModel = (target, vm)
        return vm
    }
    
    // MARK: - Views
    func makeReportView(target: ReportTarget, commentInfo: CommentReportInfo? = nil) -> ReportView {
        let vm = makeReportViewModel(target: target, commentInfo: commentInfo)
        return ReportView(
            vm: vm,
            navigationRouter: navigationRouter,
            onClear: { [weak self] in
                // 뒤로가기 시 신고 플로우 종료
                self?.clearCurrentReport()
            },
            onSubmit: { [weak navigationRouter] in
                navigationRouter?.navigate(to: .reportDetail(target: target, commentInfo: commentInfo))
            }
        )
    }

    func makeReportDetailView(target: ReportTarget, commentInfo: CommentReportInfo? = nil) -> ReportDetailView {
        let vm = makeReportViewModel(target: target, commentInfo: commentInfo)
        let router = navigationRouter
        let capturedCommentInfo = commentInfo

        // 신고 완료/중복 후 원래 화면으로 돌아가는 공통 로직
        let navigateBack: () -> Void = { [weak self] in
            self?.clearCurrentReport()

            switch target {
            case .post(let id):
                router.showSuccessAndNavigate(
                    message: "신고가 접수되었습니다",
                    to: .feed,
                    destination: .feedDetail(feedId: id),
                    duration: 2.0
                )
            case .comment:
                let feedId = capturedCommentInfo?.feedId ?? 0
                guard feedId > 0 else { return }

                router.showSuccessAndNavigate(
                    message: "신고가 접수되었습니다",
                    to: .feed,
                    destination: .feedDetail(feedId: feedId),
                    duration: 2.0
                )

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    router.presentSheet(for: .comment(feedId: feedId))
                }
            }
        }

        let tokenService = tokenService
        return ReportDetailView(
            vm: vm,
            navigationRouter: navigationRouter,
            onSubmit: {
                Task { @MainActor in
                    guard let reporterId = tokenService.getCurrentUserId() else {
                        vm.errorMessage = "로그인 정보를 가져올 수 없습니다. 다시 로그인해주세요."
                        return
                    }
                    let result = await vm.submit(reporterId: reporterId)
                    if result != nil {
                        navigateBack()
                    }
                }
            },
            onDuplicateDismiss: {
                navigateBack()
            }
        )
    }
}
