//
//  ClosetDIContainer.swift
//  Codive
//
//  Created by gemini on 2025/11/22.
//

import Foundation

final class ClosetDIContainer {

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
}
