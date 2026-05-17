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
    /// - Note: 중복 체크는 "오늘" 기록을 작성하는 경우(selectedDate가 nil이거나 오늘)에만 수행한다.
    ///   달력에서 과거 등 특정 날짜를 선택해 들어온 경우에는 해당 날짜에 기록이 없는 것이
    ///   이미 보장되므로 오늘 기록 여부와 무관하게 바로 기록 추가 화면으로 이동한다.
    func checkAndNavigateToRecordAdd(selectedDate: Date? = nil) {
        let isRecordingForToday = selectedDate.map { Calendar.current.isDateInToday($0) } ?? true
        guard isRecordingForToday else {
            navigationRouter.navigate(to: .recordAdd(selectedDate: selectedDate))
            return
        }
        Task {
            let hasTodayRecord = await checkTodayRecordUseCase.execute()
            if hasTodayRecord {
                isDuplicateRecordModalPresented = true
            } else {
                navigationRouter.navigate(to: .recordAdd(selectedDate: selectedDate))
            }
        }
    }

    /// 오늘 기록이 있는지만 확인 (외부에서 분기 처리용)
    func checkTodayRecordExists() async -> Bool {
        await checkTodayRecordUseCase.execute()
    }
    
    // MARK: - Actions
    func handleSearchTap() {
        navigationRouter.navigate(to: .search)
    }

    func handleNotificationTap() {
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
