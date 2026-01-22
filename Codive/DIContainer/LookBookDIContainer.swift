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
    
    private lazy var lookBookAPIService: LooBookAPIServiceProtocol = {
        return LooBookAPIService()
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
        lookbookId: Int,
        lookbookTitle: String = ""
    ) -> SpecificLookBookViewModel {
        return SpecificLookBookViewModel(
            navigationRouter: navigationRouter,
            specificLookBookUseCase: makeSpecificLookBookUseCase(),
            lookbookId: lookbookId,
            lookbookTitle: lookbookTitle
        )
    }
    
    func makeSpecificLookBookView(
        lookbookId: Int,
        lookbookTitle: String = ""
    ) -> SpecificLookBookView {
        return SpecificLookBookView(
            viewModel: makeSpecificLookBookViewModel(
                lookbookId: lookbookId,
                lookbookTitle: lookbookTitle
            )
        )
    }
    
    // MARK: - Add Codi
    func makeAddCodiViewModel(
        coordinateId: Int
    ) -> AddCodiViewModel {
        return AddCodiViewModel(
            navigationRouter: navigationRouter,
            coordinateId: coordinateId
        )
    }
    
    func makeAddCodiView(
        coordinateId: Int
    ) -> AddCodiView {
        return AddCodiView(
            viewModel: makeAddCodiViewModel(
                coordinateId: coordinateId
            )
        )
    }
    
    // MARK: - Add Codi Detail
    func makeAddCodiDetailViewModel(lookbookId: Int) -> AddCodiDetailViewModel {
        return AddCodiDetailViewModel(
            navigationRouter: navigationRouter,
            productUseCase: makeProductUseCase(),
            lookbookId: lookbookId
        )
    }
    
    func makeAddCodiDetailView(lookbookId: Int) -> AddCodiDetailView {
        return AddCodiDetailView(
            viewModel: makeAddCodiDetailViewModel(lookbookId: lookbookId)
        )
    }
    
    // MARK: - Add Before Codi
    func makeAddBeforeCodiViewModel(coordinateId: Int) -> AddBeforeCodiViewModel {
        return AddBeforeCodiViewModel(
            navigationRouter: navigationRouter,
            beforeCodiUseCase: makeBeforeCodiUseCase(),
            coordinateId: coordinateId
        )
    }
    
    func makeAddBeforeCodiView(coordinateId: Int) -> AddBeforeCodiView {
        return AddBeforeCodiView(
            viewModel: makeAddBeforeCodiViewModel(coordinateId: coordinateId)
        )
    }
    
    // MARK: - Codi Detail
    func makeCodiDetailViewModel(
        codiId: Int,
        lookbookId: Int
    ) -> CodiDetailViewModel {
        return CodiDetailViewModel(
            navigationRouter: navigationRouter,
            codiUseCase: makeCodiUseCase(),
            specificLookBookUseCase: makeSpecificLookBookUseCase(),
            codiId: codiId,
            lookbookId: lookbookId
        )
    }
    
    func makeCodiDetailView(
        codiId: Int,
        lookbookId: Int
    ) -> CodiDetailView {
        return CodiDetailView(
            viewModel: makeCodiDetailViewModel(
                codiId: codiId,
                lookbookId: lookbookId
            )
        )
    }
    
    // MARK: - Edit Codi
    func makeEditCodiViewModel(
        lookbookId: Int,
        selectedCodiData: SelectedCodi
    ) -> EditCodiViewModel {
        return EditCodiViewModel(
            navigationRouter: navigationRouter,
            lookbookId: lookbookId,
            selectedCodiData: selectedCodiData
        )
    }
    
    func makeEditCodiView(
        lookbookId: Int,
        selectedCodiData: SelectedCodi
    ) -> EditCodiView {
        return EditCodiView(
            viewModel: makeEditCodiViewModel(
                lookbookId: lookbookId,
                selectedCodiData: selectedCodiData
            )
        )
    }
}
