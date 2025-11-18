//
//  SearchViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: SearchUseCase
    
    @Published var recommendedNews: [NewsEntity] = []
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: SearchUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        
        loadData()
    }
    
    func loadData() {
        self.recommendedNews = useCase.fetchRecommendedNews()
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
// MARK: - Preview Support
extension SearchViewModel {
    static var preview: SearchViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = SearchDataSource()
        let mockRepository = SearchRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = SearchUseCase(repository: mockRepository)
        
        return SearchViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase
        )
    }
}
