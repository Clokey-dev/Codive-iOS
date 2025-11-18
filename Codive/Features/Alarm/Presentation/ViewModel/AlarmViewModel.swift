//
//  AlarmViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

@MainActor
final class AlarmViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: AlarmUseCase
    
    init(navigationRouter: NavigationRouter, useCase: AlarmUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}

extension AlarmViewModel {
    static var preview: AlarmViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = AlarmDataSource()
        let mockRepository = AlarmRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = AlarmUseCase(repository: mockRepository)
        
        return AlarmViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase
        )
    }
}
