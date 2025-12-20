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

    // MARK: - DataSources
    private lazy var clothDataSource: ClothDataSource = {
        return DefaultClothDataSource()
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

    // MARK: - ViewModels
    func makeMyClosetViewModel() -> MyClosetViewModel {
        return MyClosetViewModel(
            navigationRouter: navigationRouter,
            fetchMyClosetClothItemsUseCase: makeFetchMyClosetClothItemsUseCase(),
            deleteClothItemsUseCase: makeDeleteClothItemsUseCase()
        )
    }

    func makeClothDetailViewModel(cloth: Cloth) -> ClothDetailViewModel {
        return ClothDetailViewModel(
            cloth: cloth,
            navigationRouter: navigationRouter,
            deleteClothItemsUseCase: makeDeleteClothItemsUseCase()
        )
    }

    // MARK: - Views
    func makeMyClosetView() -> some View {
        return MyClosetView(viewModel: makeMyClosetViewModel())
            .navigationBarHidden(true)
    }

    func makeClothDetailView(cloth: Cloth) -> some View {
        return ClothDetailView(viewModel: makeClothDetailViewModel(cloth: cloth))
            .navigationBarHidden(true)
    }
}
