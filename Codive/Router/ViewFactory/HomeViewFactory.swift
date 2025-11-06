//
//  HomeViewFactory.swift
//  Codive
//
//  Created by 한금준 on 11/5/25.
//

import SwiftUI

@MainActor
final class HomeViewFactory {
    
    // MARK: - Properties
    private weak var homeDIContainer: HomeDIContainer?
    
    // MARK: - Initializer
    init(homeDIContainer: HomeDIContainer) {
        self.homeDIContainer = homeDIContainer
    }
    
    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .editCategory:
            homeDIContainer?.makeEditCategoryView()
        case .codiBoard:
            homeDIContainer?.makeCodiBoardView()
        default:
            EmptyView()
        }
    }
}
