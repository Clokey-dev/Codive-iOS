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
    
    /// 알림 클릭 시 읽음 처리 로직
    func markAsRead(notificationId: Int) {
        // 1. 읽지 않은 알림 목록에서 해당 아이템 찾기
        if let index = unreadNotifications.firstIndex(where: { $0.notificationId == notificationId }) {
            // 2. 해당 아이템 추출 및 상태 변경 (실제 앱에선 여기서 API 호출을 수행합니다)
            let readItem = unreadNotifications.remove(at: index)
            
            // 3. 상태가 변경된 새 객체 생성 (Entity가 struct이므로 새로 생성)
            let updatedItem = NotificationEntity(
                notificationId: readItem.notificationId,
                notificationImageUrl: readItem.notificationImageUrl,
                notificationContent: readItem.notificationContent,
                redirectInfo: readItem.redirectInfo,
                redirectType: readItem.redirectType,
                readStatus: .read, // 읽음으로 변경
                createdAt: readItem.createdAt
            )
            
            // 4. 읽음 목록 상단에 추가 및 UI 업데이트
            readNotifications.insert(updatedItem, at: 0)
        }
    }
    
    /// 알림 목록을 필터링하여 unread/read로 나누는 공통 로직
    private func updateNotificationLists(_ all: [NotificationEntity]) {
        self.unreadNotifications = all.filter { $0.readStatus == .unread }
        self.readNotifications = all.filter { $0.readStatus == .read }
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
