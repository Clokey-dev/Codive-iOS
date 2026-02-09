//
//  LookBookDIContainer.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation

@MainActor
final class LookBookDIContainer {
    
    // MARK: - Core Dependencies
    let navigationRouter: NavigationRouter
    
    private lazy var lookBookAPIService: LookBookAPIServiceProtocol = {
        return LookBookAPIService()
    }()
    
    // MARK: - Factories
    lazy var lookBookViewFactory = LookBookViewFactory(lookBookDIContainer: self)
    
    // MARK: - DataSources
    private lazy var lookBookDataSource: LookBookDataSource = {
        return LookBookDataSource(apiService: lookBookAPIService)
    }()
    
    // MARK: - Repositories
    private lazy var lookBookRepository: LookBookRepository = {
        return LookBookRepositoryImpl(datasource: lookBookDataSource)
    }()
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - UseCases
    
    func makeLookBookListUseCase() -> LookBookMainUseCase {
        return LookBookMainUseCase(repository: lookBookRepository)
    }
    
    func makeSpecificLookBookUseCase() -> SpecificLookBookUseCase {
        return SpecificLookBookUseCase(repository: lookBookRepository)
    }
    
    func makeCodiUseCase() -> CodiUseCase {
        return CodiUseCase(repository: lookBookRepository)
    }
    
    func makeProductUseCase() -> ProductUseCase {
        return ProductUseCase(repository: lookBookRepository)
    }
    
    func makeBeforeCodiUseCase() -> BeforeCodiUseCase {
        return BeforeCodiUseCase(repository: lookBookRepository)
    }
    
    // MARK: - LookBook
    func makeLookBookViewModel() -> LookBookViewModel {
        return LookBookViewModel(
            navigationRouter: navigationRouter,
            listUseCase: makeLookBookListUseCase()
        )
    }
    
    func makeLookBookView() -> LookBookView {
        return LookBookView(
            viewModel: makeLookBookViewModel()
        )
    }
    
    // MARK: - Specific LookBook
    func makeSpecificLookBookViewModel(
        lookbookId: Int64,
        name: String
    ) -> SpecificLookBookViewModel {
        return SpecificLookBookViewModel(
            navigationRouter: navigationRouter,
            specificLookBookUseCase: makeSpecificLookBookUseCase(),
            lookbookId: lookbookId,
            name: name
        )
    }
    
    func makeSpecificLookBookView(
        lookbookId: Int64,
        name: String
    ) -> SpecificLookBookView {
        return SpecificLookBookView(
            viewModel: makeSpecificLookBookViewModel(
                lookbookId: lookbookId,
                name: name
            )
        )
    }
    
    // MARK: - Add Codi
    func makeAddCodiViewModel(
        lookBookId: Int64
    ) -> AddCodiViewModel {
        return AddCodiViewModel(
            navigationRouter: navigationRouter,
            codiUseCase: makeCodiUseCase(),
            lookBookId: lookBookId
        )
    }
    
    func makeAddCodiView(
        lookBookId: Int64
    ) -> AddCodiView {
        return AddCodiView(
            viewModel: makeAddCodiViewModel(
                lookBookId: lookBookId
            )
        )
    }
    
    // MARK: - Add Codi Detail
    func makeAddCodiDetailViewModel() -> AddCodiDetailViewModel {
        return AddCodiDetailViewModel(
            navigationRouter: navigationRouter,
            productUseCase: makeProductUseCase(),
        )
    }
    
    func makeAddCodiDetailView() -> AddCodiDetailView {
        return AddCodiDetailView(
            viewModel: makeAddCodiDetailViewModel()
        )
    }
    
    // MARK: - Add Before Codi
    func makeAddBeforeCodiViewModel(coordinateId: Int64) -> AddBeforeCodiViewModel {
        return AddBeforeCodiViewModel(
            navigationRouter: navigationRouter,
            beforeCodiUseCase: makeBeforeCodiUseCase(),
            coordinateId: coordinateId
        )
    }
    
    func makeAddBeforeCodiView(coordinateId: Int64) -> AddBeforeCodiView {
        return AddBeforeCodiView(
            viewModel: makeAddBeforeCodiViewModel(coordinateId: coordinateId)
        )
    }
    
    // MARK: - Codi Detail
    func makeCodiDetailViewModel(
        coordinateId: Int64
    ) -> CodiDetailViewModel {
        return CodiDetailViewModel(
            navigationRouter: navigationRouter,
            codiUseCase: makeCodiUseCase(),
            specificLookBookUseCase: makeSpecificLookBookUseCase(),
            coordinateId: coordinateId
        )
    }
    
    func makeCodiDetailView(
        coordinateId: Int64,
    ) -> CodiDetailView {
        return CodiDetailView(
            viewModel: makeCodiDetailViewModel(
                coordinateId: coordinateId
            )
        )
    }
    
    // MARK: - Edit Codi
    func makeEditCodiViewModel(
        selectedCodiData: SelectedCodi
    ) -> EditCodiViewModel {
        return EditCodiViewModel(
            navigationRouter: navigationRouter,
            codiUseCase: makeCodiUseCase(),
            selectedCodiData: selectedCodiData
        )
    }
    
    func makeEditCodiView(
        selectedCodiData: SelectedCodi
    ) -> EditCodiView {
        return EditCodiView(
            viewModel: makeEditCodiViewModel(
                selectedCodiData: selectedCodiData
            )
        )
    }
}
