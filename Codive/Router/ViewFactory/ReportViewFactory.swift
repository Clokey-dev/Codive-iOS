//
//  ReportViewFactory.swift
//  Codive
//
//  Created by 한태빈 on 11/14/25.
//

import SwiftUI

struct ReportViewFactory {

    unowned let container: ReportDIContainer

    init(reportDIContainer: ReportDIContainer) {
        self.container = reportDIContainer
    }

    @MainActor
    func makeReportView(target: ReportTarget) -> ReportView {
        container.makeReportView(target: target)
    }

    @MainActor
    func makeReportDetailView(target: ReportTarget) -> ReportDetailView {
        container.makeReportDetailView(target: target)
    }
}
