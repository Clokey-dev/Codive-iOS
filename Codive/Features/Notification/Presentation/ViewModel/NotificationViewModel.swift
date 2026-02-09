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
    
    @Published var unreadNotifications: [NotificationListResponseItem] = []
    @Published var readNotifications: [NotificationListResponseItem] = []
    
    @Published var isReported: Bool = false
    @Published var reportType: ReportType?
    @Published var readErrorMessage: String?
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: NotificationUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Methods
    func loadData() {
        Task {
            do {
                let result = try await useCase.fetchNotificationList(
                    lastNotificationId: nil,
                    size: 20
                )
                
                updateNotificationLists(result.content)
                
                let reportResult = try await useCase.fetchReportReceived()
                self.isReported = reportResult.isReported
                
                if reportResult.isReported {
                    self.reportType = reportResult.targetType
                } else {
                    self.reportType = nil
                }
            } catch {
                print(error)
            }
        }
    }
    
    func markAsRead(notificationId: Int64) {
        Task {
            do {
                try await useCase.patchEachNotification(notificationId: notificationId)
                
                if let index = unreadNotifications.firstIndex(where: { $0.notificationId == notificationId }) {
                    var readItem = unreadNotifications.remove(at: index)
                    readItem = NotificationListResponseItem(
                        notificationId: readItem.notificationId,
                        notificationImageUrl: readItem.notificationImageUrl,
                        notificationContent: readItem.notificationContent,
                        notificationType: readItem.notificationType,
                        action: readItem.action,
                        readStatus: .read,
                        createdAt: readItem.createdAt
                    )
                    readNotifications.insert(readItem, at: 0)
                }
            } catch {
                readErrorMessage = "알림 읽음 처리에 실패했어요."
            }
        }
    }
    
    private func updateNotificationLists(_ all: [NotificationListResponseItem]) {
        unreadNotifications = all.filter { $0.readStatus == .notRead }
        readNotifications = all.filter { $0.readStatus == .read }
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
