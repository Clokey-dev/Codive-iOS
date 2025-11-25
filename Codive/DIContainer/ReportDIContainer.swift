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
    
    // MARK: - Init
    init(
        appRouter: AppRouter,
        navigationRouter: NavigationRouter
    ) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
        
        let dataSource = ReportDataSource()
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
        let vm = makeReportViewModel(target: target)
        return ReportView(vm: vm) { [weak navigationRouter] in
            navigationRouter?.navigate(to: .reportDetail(target: target))
        }
    }

    func makeReportDetailView(target: ReportTarget) -> ReportDetailView {
        let vm = makeReportViewModel(target: target)
        return ReportDetailView(vm: vm)
    }
}
