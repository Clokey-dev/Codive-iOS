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
    lazy var searchViewFactory = SearchViewFactory(searchDIContainer: self)
    
    lazy var searchDataSource = SearchDataSource()
    
    lazy var searchRepository: SearchRepository = SearchRepositoryImpl(datasource: searchDataSource)
    
    lazy var searchUseCase = SearchUseCase(repository: searchRepository)
    
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel(
            navigationRouter: navigationRouter,
            useCase: searchUseCase
        )
    }
    
    func makeSearchResultViewModel(initialQuery: String) -> SearchResultViewModel {
        return SearchResultViewModel(
            navigationRouter: navigationRouter,
            useCase: searchUseCase,
            initialQuery: initialQuery
        )
    }
    
    func makeSearchView() -> SearchView {
        return SearchView(viewModel: makeSearchViewModel())
    }
    
    func makeSearchResultView(initialQuery: String) -> SearchResultView {
        return SearchResultView(viewModel: makeSearchResultViewModel(initialQuery: initialQuery))
    }
}
