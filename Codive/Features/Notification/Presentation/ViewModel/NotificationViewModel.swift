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
                // 1️⃣ 알림 목록 조회
                let result = try await useCase.fetchNotificationList(
                    lastNotificationId: nil,
                    size: 20
                )
                
                // 2️⃣ unread / read 분리
                updateNotificationLists(result.content)
                
                // 3️⃣ 신고 상태 조회 (기존 동기 로직 유지)
//                let reportStatus = useCase.fetchReportStatus()
//                self.isReported = reportStatus.isReported
//                self.reportType = reportStatus.reportType
                
                // 4️⃣ 성공 로그
                print("✅ Notification fetch success")
                print("isLast:", result.isLast)
                print("total:", result.content.count)
                
            } catch {
                print("❌ Notification fetch failed:", error)
            }
        }
    }
    
    func markAsRead(notificationId: Int64) {
        Task {
            do {
                try await useCase.patchEachNotification(notificationId: notificationId)
                
                if let index = unreadNotifications.firstIndex(where: { $0.notificationId == notificationId }) {
                    var readItem = unreadNotifications.remove(at: index)
                    readItem.readStatus = .read
                    readNotifications.insert(readItem, at: 0)
                }
                
                print("✅ Notification marked as read:", notificationId)
            } catch {
                readErrorMessage = "알림 읽음 처리에 실패했어요. 잠시 후 다시 시도해 주세요."
                print("❌ Notification markAsRead failed:", error)}
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
