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

    // MARK: - DataSources
    private lazy var clothDataSource: ClothDataSource = {
        return DefaultClothDataSource(apiService: clothAPIService)
    }()

    // MARK: - Repositories
    private lazy var clothRepository: ClothRepository = {
        return ClothRepositoryImpl(dataSource: clothDataSource)
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
        return DefaultClothAIUseCase(apiService: clothAPIService)
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
            clothRepository: clothRepository
        )
    }

    func makeClothEditViewModel(cloth: Cloth) -> ClothEditViewModel {
        return ClothEditViewModel(
            cloth: cloth,
            navigationRouter: navigationRouter,
            clothRepository: clothRepository
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
}
