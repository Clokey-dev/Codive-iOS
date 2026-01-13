//
//  ClothEditViewModel.swift
//  Codive
//
//  Created by 황상환 on 12/21/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - ClothEditViewModelInput
@MainActor
protocol ClothEditViewModelInput {
    func updateName(_ name: String)
    func updateBrand(_ brand: String)
    func updatePurchaseUrl(_ url: String)
    func showCategorySheet()
    func showSeasonSheet()
    func selectCategory(_ category: CategoryItem, subcategory: SubcategoryItem)
    func selectSeasons(_ seasons: Set<Season>)
    func dismissView()
    func completeEditing()
}

// MARK: - ClothEditViewModelOutput
@MainActor
protocol ClothEditViewModelOutput {
    var cloth: Cloth { get }
    var clothForm: ClothFormData { get }
    var isCategorySheetPresented: Bool { get set }
    var isSeasonSheetPresented: Bool { get set }
    var tempSelectedCategory: CategoryItem? { get set }

    var categoryDisplayText: String { get }
    var seasonDisplayText: String { get }
    var isFormValid: Bool { get }
}

// MARK: - ClothEditViewModel
@MainActor
final class ClothEditViewModel: ObservableObject, ClothEditViewModelInput, ClothEditViewModelOutput {

    // MARK: - Output Properties
    let cloth: Cloth
    @Published var clothForm: ClothFormData

    // Sheet states
    @Published var isCategorySheetPresented = false
    @Published var isSeasonSheetPresented = false
    @Published var tempSelectedCategory: CategoryItem?

    // MARK: - Dependencies
    private let navigationRouter: NavigationRouter
    // TODO: UpdateClothUseCase 추가 필요

    // MARK: - Computed Properties
    var categoryDisplayText: String {
        if let category = clothForm.category, let subcategory = clothForm.subcategory {
            return "\(category.name) > \(subcategory.name)"
        }
        return ""
    }

    var seasonDisplayText: String {
        if clothForm.selectedSeasons.isEmpty {
            return ""
        }
        // 봄 → 여름 → 가을 → 겨울 순서로 정렬
        let orderedSeasons: [Season] = [.spring, .summer, .fall, .winter]
        let sortedSeasons = orderedSeasons.filter { clothForm.selectedSeasons.contains($0) }
        return sortedSeasons.map { $0.displayName }.joined(separator: ", ")
    }

    var isFormValid: Bool {
        return clothForm.category != nil && !clothForm.selectedSeasons.isEmpty
    }

    // MARK: - Initializer
    init(
        cloth: Cloth,
        navigationRouter: NavigationRouter
    ) {
        self.cloth = cloth
        self.navigationRouter = navigationRouter

        // 기존 Cloth 데이터로 폼 초기화
        // categoryId는 하위 카테고리 ID이므로 그걸로 상위/하위 카테고리 모두 조회
        let subcategory = cloth.categoryId.flatMap { CategoryConstants.subcategory(byId: $0) }
        let category = cloth.categoryId.flatMap { CategoryConstants.category(bySubcategoryId: $0) }

        self.clothForm = ClothFormData(
            name: cloth.name ?? "",
            brand: cloth.brand ?? "",
            purchaseUrl: cloth.purchaseUrl ?? "",
            category: category,
            subcategory: subcategory,
            selectedSeasons: cloth.seasons
        )
    }

    // MARK: - Input Methods

    func updateName(_ name: String) {
        clothForm.name = name
    }

    func updateBrand(_ brand: String) {
        clothForm.brand = brand
    }

    func updatePurchaseUrl(_ url: String) {
        clothForm.purchaseUrl = url
    }

    func showCategorySheet() {
        tempSelectedCategory = clothForm.category ?? CategoryConstants.all.first
        isCategorySheetPresented = true
    }

    func showSeasonSheet() {
        isSeasonSheetPresented = true
    }

    func selectCategory(_ category: CategoryItem, subcategory: SubcategoryItem) {
        clothForm.category = category
        clothForm.subcategory = subcategory
        isCategorySheetPresented = false
    }

    func selectSeasons(_ seasons: Set<Season>) {
        clothForm.selectedSeasons = seasons
        isSeasonSheetPresented = false
    }

    func dismissView() {
        navigationRouter.navigateBack()
    }

    func completeEditing() {
        Task {
            // TODO: UpdateClothUseCase 구현 후 연결
            print("옷 수정 완료: \(cloth.id)")
            navigationRouter.navigateBack()
        }
    }
}
