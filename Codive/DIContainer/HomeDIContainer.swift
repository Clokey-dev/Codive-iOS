//
//  HomeDIContainer.swift
//  Codive
//
//  Created by 한금준 on 11/5/25.
//

import Foundation

@MainActor
final class HomeDIContainer {
    
    // MARK: - Properties
    let navigationRouter: NavigationRouter
    lazy var homeViewFactory = HomeViewFactory(homeDIContainer: self)
    
    lazy var homeDatasource = HomeDatasource()
    
    lazy var homeRepository: HomeRepository = HomeRepositoryImpl(
        dataSource: homeDatasource
    )
    
    lazy var homeUseCase = HomeUseCase(repository: homeRepository)
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    func homeViewModel() -> HomeViewModel {
        return HomeViewModel(
            navigationRouter: navigationRouter,
            useCase: homeUseCase
        )
    }
    
    func makeEditCategoryViewModel() -> EditCategoryViewModel {
        return EditCategoryViewModel(navigationRouter: navigationRouter, useCase: homeUseCase)
    }
    
    func makeCodiBoardViewModel() -> CodiBoardViewModel {
        return CodiBoardViewModel(
            navigationRouter: navigationRouter, useCase: homeUseCase
        )
    }
    
    func makeEditCategoryView() -> EditCategoryView {
        return EditCategoryView(viewModel: makeEditCategoryViewModel())
    }
    
    func makeCodiBoardView() -> CodiBoardView {
        return CodiBoardView(
            viewModel: makeCodiBoardViewModel()
        )
    }
}
