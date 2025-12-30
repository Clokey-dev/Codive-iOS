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
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: NotificationUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Methods
    func loadData() {
        let allNotifications = useCase.fetchNotifications()
        
        // readStatus Enum 값을 직접 비교하여 필터링
        self.unreadNotifications = allNotifications.filter { $0.readStatus == .unread }
        self.readNotifications = allNotifications.filter { $0.readStatus == .read }
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
