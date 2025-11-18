//
//  SearchViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: SearchUseCase
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: SearchUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
