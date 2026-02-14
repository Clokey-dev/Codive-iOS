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
    func makeReportViewModel(target: ReportTarget) -> ReportViewModel {
        // 같은 target의 현재 진행중인 신고가 있으면 재사용 (ReportView → ReportDetailView 이동 시)
        if let current = currentReportViewModel, current.target == target {
            return current.viewModel
        }

        // 새로운 신고 플로우 시작
        let vm = ReportViewModel(
            target: target,
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
    func makeReportView(target: ReportTarget) -> ReportView {
        let vm = makeReportViewModel(target: target)
        return ReportView(
            vm: vm,
            navigationRouter: navigationRouter,
            onClear: { [weak self] in
                // 뒤로가기 시 신고 플로우 종료
                self?.clearCurrentReport()
            }
        ) { [weak navigationRouter] in
            navigationRouter?.navigate(to: .reportDetail(target: target))
        }
    }

    func makeReportDetailView(target: ReportTarget) -> ReportDetailView {
        let vm = makeReportViewModel(target: target)
        return ReportDetailView(vm: vm, navigationRouter: navigationRouter) { [weak navigationRouter, weak self] in
            Task {
                // 신고 제출 - JWT 토큰에서 현재 사용자 ID 추출
                guard let reporterId = self?.tokenService.getCurrentUserId() else {
                    print("❌ 신고 실패: 현재 로그인한 사용자 ID를 가져올 수 없습니다.")
                    return
                }
                let result = await vm.submit(reporterId: reporterId)
                if result != nil {
                    // 신고 플로우 종료 - 다음 신고 시 새로운 ViewModel 생성
                    await MainActor.run {
                        self?.clearCurrentReport()
                    }

                    // 성공 시: CustomSuccessView 표시 + FeedDetailView로 이동
                    DispatchQueue.main.async {
                        // post id = feedId 이므로 feedId 추출
                        let feedId: Int
                        switch target {
                        case .post(let id):
                            feedId = id
                        case .comment:
                            feedId = 0  // 댓글 신고는 아직 미구현
                        }

                        navigationRouter?.showSuccessAndNavigate(
                            message: "신고가 접수되었습니다",
                            to: .feed,
                            destination: .feedDetail(feedId: feedId),
                            duration: 2.0
                        )
                    }
                }
            }
        }
    }
}
