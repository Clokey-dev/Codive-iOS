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
    
    var hasChanges: Bool {
        for i in categories.indices {
            let current = categories[i]
            let initial = initialCategories[i]
            
            if !current.isDefaultCategory && current.itemCount != initial.itemCount {
                return true
            }
        }
        return false
    }

    var isApplyButtonEnabled: Bool {
        let nonDefaultCategories = categories.filter { !$0.isDefaultCategory }
        return nonDefaultCategories.contains { $0.itemCount > 0 }
    }
    
    @Published var categories: [CategoryEntity] = []
    @Published var showExitAlert: Bool = false

    private var initialCategories: [CategoryEntity] = []
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: HomeUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        loadInitialData()
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        categories = useCase.loadCategories()
        initialCategories = categories
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
        
        // 기본 카테고리는 1 미만으로 내려갈 수 없음
        if category.isDefaultCategory {
            if categories[index].itemCount > 1 {
                categories[index].itemCount -= 1
            }
        } else {
            if categories[index].itemCount > 0 {
                categories[index].itemCount -= 1
            }
        }
    }
    
    // MARK: - Reset
    func resetCounts() {
        for i in categories.indices {
            if categories[i].isDefaultCategory {
                categories[i].itemCount = 1
            } else {
                categories[i].itemCount = 0
            }
        }
    }
    
    // MARK: - Apply Changes
    func applyChanges() {
        useCase.updateCategories(categories)
        navigationRouter.navigateBack()
    }
    // MARK: - Navigation
    func handleBackTap() {
        if hasChanges {
            showExitAlert = true
        } else {
            navigationRouter.navigateBack()
        }
    }
    
    func confirmExit() {
        showExitAlert = false
        navigationRouter.navigateBack()
    }

    func cancelExit() {
        showExitAlert = false
    }
}
