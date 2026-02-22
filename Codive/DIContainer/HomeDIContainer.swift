//
//  HomeDIContainer.swift
//  Codive
//
//  Created by 한금준 on 11/5/25.
//

import Foundation
import SwiftUI

@MainActor
final class HomeDIContainer {
    
    // MARK: - Properties
    let navigationRouter: NavigationRouter
    lazy var homeViewFactory = HomeViewFactory(homeDIContainer: self)

    private lazy var lookBookDIContainer: LookBookDIContainer = {
        LookBookDIContainer(navigationRouter: navigationRouter)
    }()
    
    let locationService: LocationService = SystemLocationService()
    
    private lazy var homeAPIService: HomeAPIServiceProtocol = {
        return HomeAPIService()
    }()
    // HomeViewModel 싱글톤 인스턴스 저장
    private var homeViewModel: HomeViewModel?
    
    // MARK: - DataSources
    private lazy var homeDatasource: HomeDatasource = {
        HomeDatasource(locationService: locationService, apiService: homeAPIService)
    }()
    
    // MARK: - Repositories
    private lazy var homeRepository: HomeRepository = {
        HomeRepositoryImpl(dataSource: homeDatasource)
    }()
    
    // MARK: - UseCases (각 기능별)
    
    func makeFetchWeatherUseCase() -> FetchWeatherUseCase {
        FetchWeatherUseCase(repository: homeRepository)
    }
    
    func makeCategoryUseCase() -> CategoryUseCase {
        CategoryUseCase(repository: homeRepository)
    }
    
    func makeCodiBoardUseCase() -> CodiBoardUseCase {
        CodiBoardUseCase(repository: homeRepository)
    }
    
    func makeTodayCodiUseCase() -> TodayCodiUseCase {
        TodayCodiUseCase(repository: homeRepository)
    }
    
    func makeDateUseCase() -> DateUseCase {
        DateUseCase(repository: homeRepository)
    }
    
    func makeAddToLookBookUseCase() -> AddToLookBookUseCase {
        AddToLookBookUseCase(repository: homeRepository)
    }
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - ViewModels
    
    func makeHomeViewModel() -> HomeViewModel {
        if let existingViewModel = homeViewModel {
            return existingViewModel
        }
        
        let viewModel = HomeViewModel(
            navigationRouter: navigationRouter,
            fetchWeatherUseCase: makeFetchWeatherUseCase(),
            todayCodiUseCase: makeTodayCodiUseCase(),
            dateUseCase: makeDateUseCase(),
            categoryUseCase: makeCategoryUseCase(),
            addToLookBookUseCase: makeAddToLookBookUseCase()
        )

        homeViewModel = viewModel
        return viewModel
    }
    
    func makeEditCategoryViewModel() -> EditCategoryViewModel {
        return EditCategoryViewModel(
            navigationRouter: navigationRouter,
            onApply: { [weak self] in
                guard let self, let homeViewModel = self.homeViewModel else { return }
                homeViewModel.refreshAfterCategoryEdit()
            }
        )
    }
    
    func makeCodiBoardViewModel() -> CodiBoardViewModel {
        return CodiBoardViewModel(
            navigationRouter: navigationRouter,
            codiBoardUseCase: makeCodiBoardUseCase(),
            todayCodiUseCase: makeTodayCodiUseCase(),
            homeViewModel: homeViewModel
        )
    }
    
    // MARK: - Views
    
    func makeEditCategoryView() -> EditCategoryView {
        return EditCategoryView(
            viewModel: makeEditCategoryViewModel()
        )
    }
    
    func makeCodiBoardView() -> CodiBoardView {
        return CodiBoardView(
            viewModel: makeCodiBoardViewModel()
        )
    }
    
    func makeLookBookView() -> some View {
        lookBookDIContainer.makeLookBookView()
    }
}
