//
//  SearchResultViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/19/25.
//

import SwiftUI

@MainActor
final class SearchResultViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: SearchUseCase
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: SearchUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}

// MARK: - Preview Support
extension SearchResultViewModel {
    static var preview: SearchResultViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = SearchDataSource()
        let mockRepository = SearchRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = SearchUseCase(repository: mockRepository)
        
        return SearchResultViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase
        )
    }
}

