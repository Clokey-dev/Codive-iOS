//
//  LookBookViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import SwiftUI

@MainActor
final class LookBookViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}

extension LookBookViewModel {
    static var preview: LookBookViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = LookBookDataSource()
        let mockRepository = LookBookRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = LookBookUseCase(repository: mockRepository)
        return LookBookViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase
        )
    }
}
