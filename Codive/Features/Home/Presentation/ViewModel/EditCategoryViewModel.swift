//
//  EditCategoryViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

@MainActor
final class EditCategoryViewModel: ObservableObject {
    
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: HomeUseCase
    var totalCount: Int { categories.reduce(0) { $0 + $1.itemCount } }
    
    @Published var categories: [CategoryEntity] = []
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: HomeUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        loadInitialData()
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        categories = useCase.loadCategories()
    }
    
    // MARK: - Category Count Handling
    func incrementCount(for category: CategoryEntity) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        if totalCount < 10 {
            categories[index].itemCount += 1
        }
    }
    
    func decrementCount(for category: CategoryEntity) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        if categories[index].itemCount > 0 {
            categories[index].itemCount -= 1
        }
    }
    
    // MARK: - Reset
    func resetCounts() {
        for i in categories.indices { categories[i].itemCount = 0 }
    }
    
    // MARK: - Apply Changes
    func applyChanges() {
        useCase.updateCategories(categories)
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
