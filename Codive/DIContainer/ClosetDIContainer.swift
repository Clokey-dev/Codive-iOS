//
//  ClosetDIContainer.swift
//  Codive
//
//  Created by 황상환 on 2025/11/22.
//

import Foundation
import SwiftUI

@MainActor
final class ClosetDIContainer {

    // MARK: - Properties
    let navigationRouter: NavigationRouter
    lazy var closetViewFactory = ClosetViewFactory(closetDIContainer: self)

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    // MARK: - Services
    private lazy var clothAPIService: ClothAPIServiceProtocol = {
        return ClothAPIService()
    }()

    private lazy var statisticsAPIService: StatisticsAPIServiceProtocol = {
        return StatisticsAPIService()
    }()

    // MARK: - DataSources
    private lazy var clothDataSource: ClothDataSource = {
        return DefaultClothDataSource(apiService: clothAPIService)
    }()

    private lazy var statisticsDataSource: StatisticsDataSource = {
        return DefaultStatisticsDataSource(apiService: statisticsAPIService)
    }()

    // MARK: - Repositories
    private lazy var clothRepository: ClothRepository = {
        return ClothRepositoryImpl(dataSource: clothDataSource)
    }()

    private lazy var statisticsRepository: StatisticsRepository = {
        return StatisticsRepositoryImpl(dataSource: statisticsDataSource)
    }()

    private lazy var clothAIRepository: ClothAIRepository = {
        return ClothAIRepositoryImpl(apiService: clothAPIService)
    }()

    // MARK: - UseCases
    func makeFetchClothItemsUseCase() -> FetchClothItemsUseCase {
        return FetchClothItemsUseCase(repository: clothRepository)
    }

    func makeAddClothUseCase() -> AddClothUseCase {
        return DefaultAddClothUseCase(repository: clothRepository)
    }

    func makeFetchMyClosetClothItemsUseCase() -> FetchMyClosetClothItemsUseCase {
        return FetchMyClosetClothItemsUseCase(repository: clothRepository)
    }

    func makeDeleteClothItemsUseCase() -> DeleteClothItemsUseCase {
        return DeleteClothItemsUseCase(repository: clothRepository)
    }
    
    func makeFetchMyLookBookListUseCase() -> FetchMyLookBookListUseCase {
        return FetchMyLookBookListUseCase(repository: clothRepository)
    }

    func makeClothAIUseCase() -> ClothAIUseCase {
        return DefaultClothAIUseCase(repository: clothAIRepository)
    }

    func makeCheckStatisticsConditionUseCase() -> CheckStatisticsConditionUseCase {
        return CheckStatisticsConditionUseCase(repository: statisticsRepository)
    }

    func makeFetchFavoriteItemsUseCase() -> FetchFavoriteItemsUseCase {
        return FetchFavoriteItemsUseCase(repository: statisticsRepository)
    }

    func makeFetchFavoriteCategoryItemsUseCase() -> FetchFavoriteCategoryItemsUseCase {
        return FetchFavoriteCategoryItemsUseCase(repository: statisticsRepository)
    }

    func makeFetchClosetUtilizationUseCase() -> FetchClosetUtilizationUseCase {
        return FetchClosetUtilizationUseCase(repository: statisticsRepository)
    }

    func makeFetchClothListByCategoryUseCase() -> FetchClothListByCategoryUseCase {
        return FetchClothListByCategoryUseCase(repository: clothRepository)
    }

    func makeFetchClothDetailUseCase() -> FetchClothDetailUseCase {
        return FetchClothDetailUseCase(repository: clothRepository)
    }

    // MARK: - ViewModels
    func makeMyClosetViewModel() -> MyClosetViewModel {
        return MyClosetViewModel(
            navigationRouter: navigationRouter,
            fetchMyClosetClothItemsUseCase: makeFetchMyClosetClothItemsUseCase(),
            deleteClothItemsUseCase: makeDeleteClothItemsUseCase()
        )
    }

    func makeMyClosetSectionViewModel() -> MyClosetSectionViewModel {
        return MyClosetSectionViewModel(
            navigationRouter: navigationRouter,
            fetchMyClosetClothItemsUseCase: makeFetchMyClosetClothItemsUseCase()
        )
    }
    
    func makeMyLookBookSectionViewModel() -> MyLookbookSectionViewModel {
        return MyLookbookSectionViewModel(
            navigationRouter: navigationRouter,
            fetchMyLookBookListUseCase: makeFetchMyLookBookListUseCase()
        )
    }

    func makeClothDetailViewModel(cloth: Cloth) -> ClothDetailViewModel {
        return ClothDetailViewModel(
            cloth: cloth,
            navigationRouter: navigationRouter,
            deleteClothItemsUseCase: makeDeleteClothItemsUseCase(),
            fetchClothDetailUseCase: makeFetchClothDetailUseCase()
        )
    }

    func makeClothEditViewModel(cloth: Cloth) -> ClothEditViewModel {
        return ClothEditViewModel(
            cloth: cloth,
            navigationRouter: navigationRouter,
            clothRepository: clothRepository
        )
    }

    func makeWardrobeReportDetailViewModel() -> WardrobeReportDetailViewModel {
        return WardrobeReportDetailViewModel(
            navigationRouter: navigationRouter,
            checkStatisticsConditionUseCase: makeCheckStatisticsConditionUseCase(),
            fetchFavoriteItemsUseCase: makeFetchFavoriteItemsUseCase(),
            fetchFavoriteCategoryItemsUseCase: makeFetchFavoriteCategoryItemsUseCase(),
            fetchClosetUtilizationUseCase: makeFetchClosetUtilizationUseCase()
        )
    }

    func makeFavoriteByCategoryViewModel(parentCategoryId: Int64) -> FavoriteByCategoryViewModel {
        return FavoriteByCategoryViewModel(
            navigationRouter: navigationRouter,
            fetchFavoriteCategoryItemsUseCase: makeFetchFavoriteCategoryItemsUseCase(),
            fetchClothListByCategoryUseCase: makeFetchClothListByCategoryUseCase(),
            parentCategoryId: parentCategoryId
        )
    }

    func makeItemDataViewModel() -> ItemDataViewModel {
        return ItemDataViewModel(
            navigationRouter: navigationRouter,
            fetchFavoriteItemsUseCase: makeFetchFavoriteItemsUseCase(),
            fetchClothListByCategoryUseCase: makeFetchClothListByCategoryUseCase()
        )
    }

    func makeWearingDataViewModel() -> WearingDataViewModel {
        return WearingDataViewModel(
            navigationRouter: navigationRouter,
            fetchClosetUtilizationUseCase: makeFetchClosetUtilizationUseCase()
        )
    }

    // MARK: - Views
    func makeMyClosetView() -> some View {
        return MyClosetView(viewModel: makeMyClosetViewModel())
    }

    func makeClothDetailView(cloth: Cloth) -> some View {
        return ClothDetailView(viewModel: makeClothDetailViewModel(cloth: cloth))
    }

    func makeClothEditView(cloth: Cloth) -> some View {
        return ClothEditView(viewModel: makeClothEditViewModel(cloth: cloth))
    }

    func makeWardrobeReportDetailView() -> some View {
        return WardrobeReportDetailView(viewModel: makeWardrobeReportDetailViewModel())
    }

    func makeFavoriteByCategoryView(parentCategoryId: Int64) -> some View {
        return FavoriteByCategoryView(viewModel: makeFavoriteByCategoryViewModel(parentCategoryId: parentCategoryId))
    }

    func makeItemDataView() -> some View {
        return ItemDataView(viewModel: makeItemDataViewModel())
    }

    func makeWearingDataView() -> some View {
        return WearingDataView(viewModel: makeWearingDataViewModel())
    }
}
