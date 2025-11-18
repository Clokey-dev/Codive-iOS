//
//  AlarmDIContainer.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import Foundation

@MainActor
final class NotificationDIContainer {
    let navigationRouter: NavigationRouter
    lazy var notificationViewFactory = NotificationViewFactory(notificationDIContainer: self)
    
    lazy var notificationDataSource = NotificationDataSource()
    
    lazy var notificationRepository: NotificationRepository = NotificationRepositoryImpl(datasource: notificationDataSource)
    
    lazy var notificationUseCase = NotificationUseCase(repository: notificationRepository)
    
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    func makeNotificationViewModel() -> NotificationViewModel {
        return NotificationViewModel(
            navigationRouter: navigationRouter,
            useCase: notificationUseCase
        )
    }
    
    func makeNotificationView() -> NotificationView {
        return NotificationView(viewModel: makeNotificationViewModel())
    }
}
