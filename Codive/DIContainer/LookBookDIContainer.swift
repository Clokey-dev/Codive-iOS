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

    // MARK: - Factories
    lazy var lookBookViewFactory = LookBookViewFactory(lookBookDIContainer: self)

    // MARK: - Data Layer
    lazy var lookBookDataSource = LookBookDataSource()
    
    lazy var lookBookRepository: LookBookRepository =
        LookBookRepositoryImpl(datasource: lookBookDataSource)

    // MARK: - Domain Layer
    lazy var lookBookUseCase = LookBookUseCase(repository: lookBookRepository)

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    // MARK: - LookBook
    func makeLookBookViewModel() -> LookBookViewModel {
        return LookBookViewModel(
            navigationRouter: navigationRouter,
            useCase: lookBookUseCase
        )
    }

    func makeLookBookView() -> LookBookView {
        return LookBookView(
            viewModel: makeLookBookViewModel(),
            lookBookDIContainer: self
        )
    }

    // MARK: - Specific LookBook
    func makeSpecificLookBookViewModel(lookbookId: Int) -> SpecificLookBookViewModel {
        return SpecificLookBookViewModel(
            navigationRouter: navigationRouter,
            useCase: lookBookUseCase,
            lookbookId: lookbookId
        )
    }

    func makeSpecificLookBookView(lookbookId: Int) -> SpecificLookBook {
        return SpecificLookBook(
            viewModel: makeSpecificLookBookViewModel(lookbookId: lookbookId)
        )
    }

    // MARK: - Add Codi
    func makeAddCodiViewModel(
        lookbookId: Int,
        selectedCodiData: SelectedCodi? = nil
    ) -> AddCodiViewModel {
        return AddCodiViewModel(
            navigationRouter: navigationRouter,
            useCase: lookBookUseCase,
            lookbookId: lookbookId,
            selectedCodiData: selectedCodiData
        )
    }

    func makeAddCodiView(
        lookbookId: Int,
        selectedCodiData: SelectedCodi? = nil
    ) -> AddCodiView {
        return AddCodiView(
            viewModel: makeAddCodiViewModel(
                lookbookId: lookbookId,
                selectedCodiData: selectedCodiData
            )
        )
    }

    // MARK: - Add Codi Detail
    func makeAddCodiDetailViewModel() -> AddCodiDetailViewModel {
        return AddCodiDetailViewModel(
            navigationRouter: navigationRouter,
            useCase: lookBookUseCase
        )
    }

    func makeAddCodiDetailView() -> AddCodiDetailView {
        return AddCodiDetailView(
            viewModel: makeAddCodiDetailViewModel()
        )
    }

    // MARK: - Add Before Codi
    func makeAddBeforeCodiViewModel(lookbookId: Int) -> AddBeforeCodiViewModel {
        return AddBeforeCodiViewModel(
            navigationRouter: navigationRouter,
            useCase: lookBookUseCase,
            lookbookId: lookbookId
        )
    }

    func makeAddBeforeCodiView(lookbookId: Int) -> AddBeforeCodiView {
        return AddBeforeCodiView(
            viewModel: makeAddBeforeCodiViewModel(lookbookId: lookbookId)
        )
    }

    // MARK: - Codi Detail
    func makeCodiDetailViewModel(codiId: Int) -> CodiDetailViewModel {
        return CodiDetailViewModel(
            navigationRouter: navigationRouter,
            useCase: lookBookUseCase,
            codiId: codiId
        )
    }

    func makeCodiDetailView(codiId: Int) -> CodiDetailView {
        return CodiDetailView(
            viewModel: makeCodiDetailViewModel(codiId: codiId)
        )
    }

    // MARK: - Edit Codi
    func makeEditCodiViewModel(
        lookbookId: Int,
        selectedCodiData: SelectedCodi
    ) -> EditCodiViewModel {
        return EditCodiViewModel(
            navigationRouter: navigationRouter,
            useCase: lookBookUseCase,
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
