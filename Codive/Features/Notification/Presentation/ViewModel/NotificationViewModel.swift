//
//  NotificationViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

@MainActor
final class NotificationViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: NotificationUseCase
    
    @Published var unreadNotifications: [NotificationEntity] = []
    @Published var readNotifications: [NotificationEntity] = []
    
    @Published var isReported: Bool = false
    @Published var reportType: ReportType? = nil
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: NotificationUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Methods
    func loadData() {
        let allNotifications = useCase.fetchNotifications()
        self.unreadNotifications = allNotifications.filter { $0.readStatus == .unread }
        self.readNotifications = allNotifications.filter { $0.readStatus == .read }
        
        let reportStatus = useCase.fetchReportStatus()
        self.isReported = reportStatus.isReported
        self.reportType = reportStatus.reportType
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
