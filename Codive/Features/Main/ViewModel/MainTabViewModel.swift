//
//  MainTabViewModel.swift
//  Codive
//
//  Created by 황상환 on 9/22/25.
//

import Foundation

@MainActor
final class MainTabViewModel: ObservableObject {
    @Published var selectedTab: TabBarType = .home
    @Published var hasUnreadNotification: Bool = false

    // MARK: - Empty History Modal State
    @Published var isEmptyHistoryModalPresented: Bool = false
    @Published var emptyHistoryModalDate: Date?

    private let navigationRouter: NavigationRouter

    private let notificationUsecase: TopNavigationNotificaionUsecase
    
    init(
        navigationRouter: NavigationRouter,
        notificationUsecase: TopNavigationNotificaionUsecase
    ) {
        self.navigationRouter = navigationRouter
        self.notificationUsecase = notificationUsecase
    }
    
    // MARK: - Actions
    func handleSearchTap() {
        // 검색 버튼 탭 처리
        // TODO: 검색 화면으로 이동하거나 검색 로직 처리
        navigationRouter.navigate(to: .search)
    }
    
    func handleNotificationTap() {
        // 알림 버튼 탭 처리
        // TODO: 알림 화면으로 이동하거나 알림 로직 처리
        navigationRouter.navigate(to: .notification)
    }
    
    func loadNotificationExist() {
        Task {
            do {
                let response = try await notificationUsecase.fetchNotificationExist()
                self.hasUnreadNotification = response.existsUnreadNotification

                print("🔔 unread notification:", response.existsUnreadNotification)
            } catch {
                print("❌ fetchNotificationExist failed:", error)
                self.hasUnreadNotification = false
            }
        }
    }
}
