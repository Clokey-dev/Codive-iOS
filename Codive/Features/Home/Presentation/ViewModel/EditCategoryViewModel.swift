//
//  EditCategoryViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

@MainActor
final class EditCategoryViewModel: ObservableObject {
    
    // MARK: - Properties (State & Storage)
    
    @Published var categories: [CategoryEntity] = []
    @Published var showExitAlert: Bool = false
    
    @AppStorage("SavedCategories") private var savedCategoriesData: Data?
    
    /// 변경 사항 확인을 위한 초기 상태 백업
    private var initialCategories: [CategoryEntity] = []
    
    // MARK: - Properties (Constants & Dependencies)
    
    private let navigationRouter: NavigationRouter
    
    /// 전체 카테고리 아이템의 최대 합계
    private let maxTotalCount = 7
    
    /// 고정 카테고리 ID (현재 비어 있음 - 필요 시 상의: 1, 바지: 2, 신발: 5 등을 추가)
    private let fixedCategoryIds: Set<Int> = []
    
    /// 기본 카테고리 구성 정보
    private static var allCategories: [CategoryEntity] = [
        CategoryEntity(id: 1, title: "상의", itemCount: 1),
        CategoryEntity(id: 2, title: "바지", itemCount: 1),
        CategoryEntity(id: 3, title: "스커트", itemCount: 0),
        CategoryEntity(id: 4, title: "아우터", itemCount: 0),
        CategoryEntity(id: 5, title: "신발", itemCount: 1),
        CategoryEntity(id: 6, title: "가방", itemCount: 0),
        CategoryEntity(id: 7, title: "패션 소품", itemCount: 0)
    ]
    
    // MARK: - Computed Properties
    
    /// 현재 선택된 모든 카테고리 아이템의 총합
    var totalCount: Int {
        categories.reduce(0) { $0 + $1.itemCount }
    }
    
    /// 처음 진입 시와 비교하여 변경 사항이 있는지 여부
    var hasChanges: Bool {
        categories.map { $0.itemCount } != initialCategories.map { $0.itemCount }
    }

    /// 적용 버튼 활성화 상태 (변경 사항이 있고, 총합이 0보다 클 때)
    var isApplyButtonEnabled: Bool {
        hasChanges && totalCount > 0
    }
    
    // MARK: - Initializer
    
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
        loadInitialData()
    }
    
    // MARK: - Data Methods (Private)
    
    /// 저장된 데이터를 불러오거나 초기 데이터를 설정
    private func loadInitialData() {
        if let data = savedCategoriesData,
           let decoded = try? JSONDecoder().decode([CategoryEntity].self, from: data) {
            
            // 데이터 로드 시 고정 항목 규칙 적용
            self.categories = decoded.map { category in
                var updated = category
                if isFixed(category: category) {
                    updated.itemCount = 1
                }
                return updated
            }
        } else {
            // 저장된 데이터가 없는 경우 기본값 사용
            self.categories = Self.allCategories
            saveToStorage(categories: Self.allCategories)
        }
        
        // 초기 비교를 위한 상태 백업
        self.initialCategories = self.categories
    }
    
    /// AppStorage에 현재 카테고리 상태를 저장
    private func saveToStorage(categories: [CategoryEntity]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            savedCategoriesData = encoded
        }
    }
    
    // MARK: - Category Logic
    
    /// 해당 카테고리가 변경 불가능한 고정 항목인지 확인
    func isFixed(category: CategoryEntity) -> Bool {
        return fixedCategoryIds.contains(category.id)
    }
    
    /// 카테고리 아이템 개수 증가 (최대 1개, 전체 7개 제한)
    func incrementCount(for category: CategoryEntity) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        
        if categories[index].itemCount < 1 && totalCount < maxTotalCount {
            categories[index].itemCount += 1
        }
    }
    
    /// 카테고리 아이템 개수 감소
    func decrementCount(for category: CategoryEntity) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        
        if categories[index].itemCount > 0 {
            categories[index].itemCount -= 1
        }
    }
    
    /// 현재 상태를 초기 상태로 되돌림
    func resetCounts() {
        self.categories = initialCategories
    }
    
    /// 변경 사항을 저장하고 이전 화면으로 이동
    func applyChanges() {
        saveToStorage(categories: categories)
        navigationRouter.navigateBack()
    }
    
    // MARK: - Navigation & Alert Handling
    
    /// 뒤로가기 버튼 탭 처리 (변경 사항 발생 시 알럿 표시)
    func handleBackTap() {
        if hasChanges {
            showExitAlert = true
        } else {
            navigationRouter.navigateBack()
        }
    }
    
    /// 알럿에서 나가기 확인 시
    func confirmExit() {
        showExitAlert = false
        navigationRouter.navigateBack()
    }

    /// 알럿에서 취소 시
    func cancelExit() {
        showExitAlert = false
    }
}
