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

    // MARK: - Views
    func makeMyClosetView() -> some View {
        return MyClosetView(navigationRouter: navigationRouter)
            .navigationBarHidden(true)
    }
}
