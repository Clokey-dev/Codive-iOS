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
    private let navigationRouter: NavigationRouter
    
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
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
    }
}
