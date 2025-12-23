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

    // MARK: - Domain Layer (UseCases)

    /// 룩북 목록/삭제
    lazy var lookBookListUseCase = LookBookListUseCase(repository: lookBookRepository)

    /// 룩북 상세(특정 룩북의 코디 리스트)
    lazy var lookBookDetailUseCase = LookBookDetailUseCase(repository: lookBookRepository)

    /// 코디 상세/좋아요
    lazy var codiUseCase = CodiUseCase(repository: lookBookRepository)

    /// 상품 목록
    lazy var productUseCase = ProductUseCase(repository: lookBookRepository)

    /// 이전 코디 목록
    lazy var beforeCodiUseCase = BeforeCodiUseCase(repository: lookBookRepository)

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    // MARK: - LookBook
    func makeLookBookViewModel() -> LookBookViewModel {
        return LookBookViewModel(
            navigationRouter: navigationRouter,
            listUseCase: lookBookListUseCase
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
            detailUseCase: lookBookDetailUseCase,
            codiUseCase: codiUseCase,
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
            productUseCase: productUseCase,
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
            beforeCodiUseCase: beforeCodiUseCase,
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
            codiUseCase: codiUseCase,
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
