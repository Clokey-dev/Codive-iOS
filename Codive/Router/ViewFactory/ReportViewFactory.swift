//
//  ReportViewFactory.swift
//  Codive
//
//  Created by 한태빈 on 11/14/25.
//
import SwiftUI

@MainActor
final class ReportViewFactory {
    
    // MARK: - Properties
    private weak var reportDIContainer: ReportDIContainer?
    
    // MARK: - Initializer
    init(reportDIContainer: ReportDIContainer) {
        self.reportDIContainer = reportDIContainer
    }
    
    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .report(let target):
            reportDIContainer?.makeReportView(target: target)
            
        case .reportDetail(let target):
            reportDIContainer?.makeReportDetailView(target: target)
            
        default:
            EmptyView()
        }
    }
}
