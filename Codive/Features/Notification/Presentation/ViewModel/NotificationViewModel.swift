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
    @Published var reportType: ReportType?
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: NotificationUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Methods
    func loadData() {
        updateNotificationLists(useCase.fetchNotifications())
        
        let reportStatus = useCase.fetchReportStatus()
        self.isReported = reportStatus.isReported
        self.reportType = reportStatus.reportType
    }

    func markAsRead(notificationId: Int) {
        Task {
            await useCase.markNotificationAsRead(notificationId: notificationId)

            if let index = unreadNotifications.firstIndex(where: { $0.notificationId == notificationId }) {
                let readItem = unreadNotifications.remove(at: index)
                
                let updatedItem = NotificationEntity(
                    notificationId: readItem.notificationId,
                    notificationImageUrl: readItem.notificationImageUrl,
                    notificationContent: readItem.notificationContent,
                    redirectInfo: readItem.redirectInfo,
                    redirectType: readItem.redirectType,
                    readStatus: .read,
                    createdAt: readItem.createdAt
                )
                
                readNotifications.insert(updatedItem, at: 0)
            }
        }
    }

    private func updateNotificationLists(_ all: [NotificationEntity]) {
        self.unreadNotifications = all.filter { $0.readStatus == .unread }
        self.readNotifications = all.filter { $0.readStatus == .read }
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
