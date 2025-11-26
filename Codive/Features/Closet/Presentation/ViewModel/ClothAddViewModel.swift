//
//  ClothAddViewModel.swift
//  Codive
//
//  Created by Claude on 11/26/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - ClothFormData
struct ClothFormData {
    var name: String = ""
    var brand: String = ""
    var purchaseUrl: String = ""
    var category: CategoryItem?
    var subcategory: String?
    var selectedSeasons: Set<Season> = []
}

// MARK: - ClothAddViewModel
@MainActor
final class ClothAddViewModel: ObservableObject {

    // MARK: - Properties
    @Published var selectedPhotos: [SelectedPhoto]
    @Published var currentIndex: Int = 0
    @Published var clothForms: [ClothFormData] = []

    // Sheet states
    @Published var isCategorySheetPresented = false
    @Published var isSeasonSheetPresented = false
    @Published var tempSelectedCategory: CategoryItem?

    private let navigationRouter: NavigationRouter

    // MARK: - Computed Properties
    var currentPhoto: SelectedPhoto? {
        guard !selectedPhotos.isEmpty, selectedPhotos.indices.contains(currentIndex) else {
            return nil
        }
        return selectedPhotos[currentIndex]
    }

    var currentForm: ClothFormData {
        guard clothForms.indices.contains(currentIndex) else {
            return ClothFormData()
        }
        return clothForms[currentIndex]
    }

    var categoryDisplayText: String {
        if let category = currentForm.category, let subcategory = currentForm.subcategory {
            return "\(category.name) > \(subcategory)"
        }
        return ""
    }

    var seasonDisplayText: String {
        if currentForm.selectedSeasons.isEmpty {
            return ""
        }
        return currentForm.selectedSeasons.map { $0.displayName }.joined(separator: ", ")
    }

    var isCurrentFormValid: Bool {
        return currentForm.category != nil && !currentForm.selectedSeasons.isEmpty
    }

    var isFirstPhoto: Bool {
        return currentIndex == 0
    }

    var isLastPhoto: Bool {
        return currentIndex == selectedPhotos.count - 1
    }

    var isSinglePhoto: Bool {
        return selectedPhotos.count == 1
    }

    // MARK: - Initializer
    init(
        selectedPhotos: [SelectedPhoto],
        navigationRouter: NavigationRouter
    ) {
        self.selectedPhotos = selectedPhotos
        self.navigationRouter = navigationRouter

        // 각 사진마다 빈 폼 데이터 초기화
        self.clothForms = Array(repeating: ClothFormData(), count: selectedPhotos.count)
    }

    // MARK: - Methods

    func updateName(_ name: String) {
        clothForms[currentIndex].name = name
    }

    func updateBrand(_ brand: String) {
        clothForms[currentIndex].brand = brand
    }

    func updatePurchaseUrl(_ url: String) {
        clothForms[currentIndex].purchaseUrl = url
    }

    func showCategorySheet() {
        tempSelectedCategory = currentForm.category ?? CategoryConstants.all.first
        isCategorySheetPresented = true
    }

    func showSeasonSheet() {
        isSeasonSheetPresented = true
    }

    func selectCategory(_ category: CategoryItem, subcategory: String) {
        clothForms[currentIndex].category = category
        clothForms[currentIndex].subcategory = subcategory
        isCategorySheetPresented = false
    }

    func selectSeasons(_ seasons: Set<Season>) {
        clothForms[currentIndex].selectedSeasons = seasons
        isSeasonSheetPresented = false
    }

    func moveToPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }

    func moveToNext() {
        if currentIndex < selectedPhotos.count - 1 {
            currentIndex += 1
        }
    }

    func dismissView() {
        navigationRouter.navigateBack()
    }

    func completeAdding() {
        // TODO: 옷 추가 완료 로직
        // 현재는 아무 동작 없음
    }
}
