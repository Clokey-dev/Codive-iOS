//
//  HomeDIContainer.swift
//  Codive
//
//  Created by 한금준 on 11/5/25.
//

import Foundation

@MainActor
final class HomeDIContainer {
    
    // MARK: - Properties
    let navigationRouter: NavigationRouter
    lazy var homeViewFactory = HomeViewFactory(homeDIContainer: self)
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    func makeEditCategoryViewModel() -> EditCategoryViewModel {
        return EditCategoryViewModel(
            navigationRouter: navigationRouter
        )
    }
    
    func makeCodiBoardViewModel() -> CodiBoardViewModel {
        return CodiBoardViewModel(
            navigationRouter: navigationRouter
        )
    }
    
    func makeEditCategoryView() -> EditCategoryView {
        return EditCategoryView(viewModel: makeEditCategoryViewModel())
    }
    
    func makeCodiBoardView() -> CodiBoardView {
        return CodiBoardView(
            viewModel: makeCodiBoardViewModel()
        )
    }
}
