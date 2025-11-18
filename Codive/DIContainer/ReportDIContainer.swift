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
    private let dataSource: ReportDataSource
    private let repository: any ReportRepository          // 신고 제출용
    private let contextProvider: any ReportContextProvider // 미리보기/컨텍스트용
    
    // MARK: - Init
    init(
        appRouter: AppRouter,
        navigationRouter: NavigationRouter
    ) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
        
        let dataSource = ReportDataSource()
        let repoImpl = ReportRepositoryImpl(dataSource: dataSource)
        
        self.dataSource = dataSource
        self.repository = repoImpl          // ReportRepository 로 사용
        self.contextProvider = repoImpl     // ReportContextProvider 로도 사용
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
        ReportViewModel(
            target: target,
            appRouter: appRouter,
            navigationRouter: navigationRouter,
            getContextUseCase: makeGetReportContextUseCase(),
            submitUseCase: makeSubmitReportUseCase()
        )
    }
    
    // MARK: - Views
    
    func makeReportView(target: ReportTarget) -> ReportView {
        ReportView(vm: makeReportViewModel(target: target))
    }
    
    // DetailView에 대하여 새 ViewModel을 만들지 않고, 이미 있는 걸 받도록 정의
    func makeReportDetailView(viewModel: ReportViewModel) -> ReportDetailView {
        ReportDetailView(vm: viewModel)
    }
}
