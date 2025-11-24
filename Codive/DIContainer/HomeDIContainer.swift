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
    let locationService: LocationService = SystemLocationService()
    
    lazy var homeDatasource = HomeDatasource(locationService: locationService)
    
    lazy var homeRepository: HomeRepository = HomeRepositoryImpl(
        dataSource: homeDatasource
    )
    
    lazy var homeUseCase = HomeUseCase(repository: homeRepository)
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            navigationRouter: navigationRouter,
            useCase: homeUseCase
        )
    }
    
    func makeEditCategoryViewModel() -> EditCategoryViewModel {
        return EditCategoryViewModel(navigationRouter: navigationRouter)
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
