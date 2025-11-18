//
//  AlarmViewModel.swift
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
    
    init(navigationRouter: NavigationRouter, useCase: NotificationUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}

extension NotificationViewModel {
    static var preview: NotificationViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = NotificationDataSource()
        let mockRepository = NotificationRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = NotificationUseCase(repository: mockRepository)
        
        return NotificationViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase
        )
    }
}
