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
    
    // 전체 최대 개수를 7로 설정
    private let maxTotalCount = 7
    // 고정 카테고리 ID (상의: 1, 바지: 2, 신발: 5)
    private let fixedCategoryIds: Set<Int> = []
    
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
        CategoryEntity(id: 1, title: "상의", itemCount: 1),
        CategoryEntity(id: 2, title: "바지", itemCount: 1),
        CategoryEntity(id: 3, title: "스커트", itemCount: 0),
        CategoryEntity(id: 4, title: "아우터", itemCount: 0),
        CategoryEntity(id: 5, title: "신발", itemCount: 1),
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
            // 저장된 데이터가 있더라도 고정 항목은 항상 1로 강제 유지
            self.categories = decodedCategories.map { category in
                var updated = category
                if fixedCategoryIds.contains(category.id) {
                    updated.itemCount = 1
                }
                return updated
            }
        } else {
            self.categories = Self.allCategories
            if let encoded = try? JSONEncoder().encode(Self.allCategories) {
                savedCategoriesData = encoded
            }
        }
        self.initialCategories = self.categories
    }
    
    // 고정 여부 확인 함수
    func isFixed(category: CategoryEntity) -> Bool {
        return fixedCategoryIds.contains(category.id)
    }
    
    // MARK: - Category Count Handling
    func incrementCount(for category: CategoryEntity) {
            // 고정 제약이 없으므로 더 자유롭게 증가 가능
            guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
            
            // 개별 카테고리 최대 1개 & 전체 합 7개 미만일 때만 증가
            if categories[index].itemCount < 1 && totalCount < maxTotalCount {
                categories[index].itemCount += 1
            }
        }
        
        func decrementCount(for category: CategoryEntity) {
            guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
            
            // 0보다 클 때만 감소 가능
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
