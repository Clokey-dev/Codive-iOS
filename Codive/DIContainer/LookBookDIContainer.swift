//
//  LookBookDIContainer.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation

@MainActor
final class LookBookDIContainer {
    let navigationRouter: NavigationRouter
    
    lazy var lookBookViewFactory = LookBookViewFactory(lookBookDIContainer: self)
    
    lazy var lookBookDataSource = LookBookDataSource()
    
    lazy var lookBookRepository: LookBookRepository = LookBookRepositoryImpl(datasource: lookBookDataSource)
    
    lazy var lookBookUseCase = LookBookUseCase(repository: lookBookRepository)
    
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
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
    
    func makeSpecificLookBookViewModel(lookbookId: Int) -> SpecificLookBookViewModel {
        return SpecificLookBookViewModel(
            navigationRouter: navigationRouter,
            useCase: lookBookUseCase,
            lookbookId: lookbookId
        )
    }
    
    func makeSpecificLookBookView(lookbookId: Int) -> SpecificLookBook {
        return SpecificLookBook(viewModel: makeSpecificLookBookViewModel(lookbookId: lookbookId))
    }
    
    func makeAddCodiViewModel(lookbookId: Int) -> AddCodiViewModel {
        return AddCodiViewModel(
            navigationRouter: navigationRouter,
            useCase: lookBookUseCase,
            lookbookId: lookbookId
        )
    }
    
    func makeAddCodiView(lookbookId: Int) -> AddCodiView {
        return AddCodiView(viewModel: makeAddCodiViewModel(lookbookId: lookbookId))
    }
    
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
}
