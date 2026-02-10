import Foundation
import SwiftUI

@MainActor
final class ReportDIContainer {

    // MARK: - Dependencies
    private let appRouter: AppRouter
    private let navigationRouter: NavigationRouter

    // ViewFactory
    lazy var reportViewFactory = ReportViewFactory(reportDIContainer: self)

    // MARK: - Data / Repository
    private let repository: any ReportRepository
    private let contextProvider: any ReportContextProvider

    // MARK: - ViewModel Cache
    private var viewModelCache: [String: ReportViewModel] = [:]
    
    // MARK: - Init
    init(
        appRouter: AppRouter,
        navigationRouter: NavigationRouter
    ) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter

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
        // 같은 target의 ViewModel이 이미 존재하면 재사용
        let key = target.id
        if let cachedVM = viewModelCache[key] {
            return cachedVM
        }

        let vm = ReportViewModel(
            target: target,
            appRouter: appRouter,
            navigationRouter: navigationRouter,
            getContextUseCase: makeGetReportContextUseCase(),
            submitUseCase: makeSubmitReportUseCase()
        )

        // ViewModel을 캐시에 저장
        viewModelCache[key] = vm
        return vm
    }
    
    // MARK: - Views
    func makeReportView(target: ReportTarget) -> ReportView {
        let vm = makeReportViewModel(target: target)
        return ReportView(vm: vm, navigationRouter: navigationRouter) { [weak navigationRouter] in
            navigationRouter?.navigate(to: .reportDetail(target: target))
        }
    }

    func makeReportDetailView(target: ReportTarget) -> ReportDetailView {
        let vm = makeReportViewModel(target: target)
        return ReportDetailView(vm: vm, navigationRouter: navigationRouter) { [weak navigationRouter] in
            Task {
                // 신고 제출 (reporterId는 현재 사용자 ID로 - 추후 UserService 주입 필요)
                let result = await vm.submit(reporterId: 1)
                if result != nil {
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
