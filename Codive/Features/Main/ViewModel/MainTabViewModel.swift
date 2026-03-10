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

    // MARK: - Duplicate Record Modal State
    @Published var isDuplicateRecordModalPresented: Bool = false

    private let navigationRouter: NavigationRouter
    private let notificationUsecase: TopNavigationNotificaionUsecase
    private let checkTodayRecordUseCase: CheckTodayRecordUseCase

    init(
        navigationRouter: NavigationRouter,
        notificationUsecase: TopNavigationNotificaionUsecase,
        checkTodayRecordUseCase: CheckTodayRecordUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.notificationUsecase = notificationUsecase
        self.checkTodayRecordUseCase = checkTodayRecordUseCase
    }

    // MARK: - Duplicate Record Check

    /// 오늘 기록이 있는지 확인 후, 없으면 기록 추가 화면으로 이동, 있으면 모달 표시
    func checkAndNavigateToRecordAdd() {
        Task {
            let hasTodayRecord = await checkTodayRecordUseCase.execute()
            if hasTodayRecord {
                isDuplicateRecordModalPresented = true
            } else {
                navigationRouter.navigate(to: .recordAdd)
            }
        }
    }

    /// 오늘 기록이 있는지만 확인 (외부에서 분기 처리용)
    func checkTodayRecordExists() async -> Bool {
        await checkTodayRecordUseCase.execute()
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

                #if DEBUG
                print("[MainTab] unread notification:", response.existsUnreadNotification)
                #endif
            } catch {
                #if DEBUG
                print("[MainTab] fetchNotificationExist failed:", error)
                #endif
                self.hasUnreadNotification = false
            }
        }
    }
}
