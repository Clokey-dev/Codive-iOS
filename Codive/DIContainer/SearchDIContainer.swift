//
//  SearchDIContainer.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import Foundation

@MainActor
final class SearchDIContainer {
    
    let navigationRouter: NavigationRouter
    
    private lazy var searchAPIService: SearchAPIServiceProtocol = {
        return SearchAPIService()
    }()
    
    // MARK: - Factories
    lazy var searchViewFactory = SearchViewFactory(searchDIContainer: self)
    
    // MARK: - DataSources
    private lazy var searchDataSource: SearchDataSource = {
        return SearchDataSource(apiService: searchAPIService)
    }()
    
    lazy var searchRepository: SearchRepository = SearchRepositoryImpl(datasource: searchDataSource)
    
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    func makeSearchUseCase() -> SearchUseCase {
        return SearchUseCase(repository: searchRepository)
    }
    
    func makeSearchView() -> SearchView {
        return SearchView(viewModel: makeSearchViewModel())
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel(
            navigationRouter: navigationRouter,
            useCase: makeSearchUseCase()
        )
    }
    
    func makeSearchResultView(initialQuery: String) -> SearchResultView {
        return SearchResultView(viewModel: makeSearchResultViewModel(initialQuery: initialQuery))
    }
    
    func makeSearchResultViewModel(initialQuery: String) -> SearchResultViewModel {
        return SearchResultViewModel(
            navigationRouter: navigationRouter,
            useCase: makeSearchUseCase(),
            initialQuery: initialQuery
        )
    }
    
    func makeRecentlySearchResultView() -> RecentlySearchResultView {
        return RecentlySearchResultView(viewModel: makeRecentlySearchResultViewModel())
    }
    
    func makeRecentlySearchResultViewModel() -> RecentlySearchResultViewModel {
        return RecentlySearchResultViewModel(
            navigationRouter: navigationRouter
        )
    }
}
