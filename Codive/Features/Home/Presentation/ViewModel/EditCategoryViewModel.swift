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
    var totalCount: Int { categories.reduce(0) { $0 + $1.itemCount } }
    
    var hasChanges: Bool {
        return categories.map { $0.itemCount } != initialCategories.map { $0.itemCount }
    }

    var isApplyButtonEnabled: Bool {
        return hasChanges && totalCount > 0
    }
    
    @AppStorage("SavedCategories") private var savedCategoriesData: Data?
    @Published var categories: [CategoryEntity] = []
    @Published var showExitAlert: Bool = false

    private var initialCategories: [CategoryEntity] = []
    
    private static var allCategories: [CategoryEntity] = [
        CategoryEntity(id: 1, title: "상의", itemCount: 0),
        CategoryEntity(id: 2, title: "바지", itemCount: 0),
        CategoryEntity(id: 3, title: "스커트", itemCount: 0),
        CategoryEntity(id: 4, title: "아우터", itemCount: 0),
        CategoryEntity(id: 5, title: "신발", itemCount: 0),
        CategoryEntity(id: 6, title: "가방", itemCount: 0),
        CategoryEntity(id: 7, title: "패션 소품", itemCount: 0)
    ]
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
        loadInitialData()
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        if let data = savedCategoriesData,
           let decodedCategories = try? JSONDecoder().decode([CategoryEntity].self, from: data) {
            self.categories = decodedCategories
        } else {
            // 앱 최초 실행 시 또는 저장된 데이터가 없을 경우
            var defaultCategories = Self.allCategories
            for i in defaultCategories.indices {
                let category = defaultCategories[i]
                if [1, 2, 5].contains(category.id) {
                    defaultCategories[i].itemCount = 1
                } else {
                    defaultCategories[i].itemCount = 0
                }
            }
            self.categories = defaultCategories
            // 초기 로드 시 바로 저장하여 Home에서도 동일하게 보이도록 함
            if let encoded = try? JSONEncoder().encode(defaultCategories) {
                savedCategoriesData = encoded
            }
        }
        self.initialCategories = self.categories
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
        self.categories = initialCategories
    }
    
    // MARK: - Apply Changes
    func applyChanges() {
        if let encoded = try? JSONEncoder().encode(categories) {
            savedCategoriesData = encoded
        }
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
