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
    @Published var showSearch = false
    @Published var showNotification = false
    
    // MARK: - Actions
    func handleSearchTap() {
        showSearch = true
    }
    
    func handleNotificationTap() {
        showNotification = true
    }
}
