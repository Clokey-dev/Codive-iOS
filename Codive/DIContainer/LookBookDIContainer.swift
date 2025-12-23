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
    
    // MARK: - DataSources
    private lazy var lookBookDataSource: LookBookDataSource = {
        return LookBookDataSource()
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
    
    func makeLookBookListUseCase() -> LookBookListUseCase {
        return LookBookListUseCase(repository: lookBookRepository)
    }
    
    func makeLookBookDetailUseCase() -> LookBookDetailUseCase {
        return LookBookDetailUseCase(repository: lookBookRepository)
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
            viewModel: makeLookBookViewModel(),
            lookBookDIContainer: self
        )
    }
    
    // MARK: - Specific LookBook
    func makeSpecificLookBookViewModel(
        lookbookId: Int,
        lookbookTitle: String = ""
    ) -> SpecificLookBookViewModel {
        return SpecificLookBookViewModel(
            navigationRouter: navigationRouter,
            detailUseCase: makeLookBookDetailUseCase(),
            codiUseCase: makeCodiUseCase(),
            lookbookId: lookbookId,
            lookbookTitle: lookbookTitle
        )
    }
    
    func makeSpecificLookBookView(
        lookbookId: Int,
        lookbookTitle: String = ""
    ) -> SpecificLookBook {
        return SpecificLookBook(
            viewModel: makeSpecificLookBookViewModel(
                lookbookId: lookbookId,
                lookbookTitle: lookbookTitle
            )
        )
    }
    
    // MARK: - Add Codi
    func makeAddCodiViewModel(
        lookbookId: Int,
        selectedCodiData: SelectedCodi? = nil
    ) -> AddCodiViewModel {
        return AddCodiViewModel(
            navigationRouter: navigationRouter,
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
    func makeAddBeforeCodiViewModel(lookbookId: Int) -> AddBeforeCodiViewModel {
        return AddBeforeCodiViewModel(
            navigationRouter: navigationRouter,
            beforeCodiUseCase: makeBeforeCodiUseCase(),
            lookbookId: lookbookId
        )
    }
    
    func makeAddBeforeCodiView(lookbookId: Int) -> AddBeforeCodiView {
        return AddBeforeCodiView(
            viewModel: makeAddBeforeCodiViewModel(lookbookId: lookbookId)
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
