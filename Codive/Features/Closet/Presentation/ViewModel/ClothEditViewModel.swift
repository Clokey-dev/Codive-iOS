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
    @Published var isLoading = false
    @Published var isFetching = false
    @Published var errorMessage: String?
    @Published var imageUrl: String = ""

    // Sheet states
    @Published var isCategorySheetPresented = false
    @Published var isSeasonSheetPresented = false
    @Published var tempSelectedCategory: CategoryItem?

    // MARK: - Dependencies
    private let navigationRouter: NavigationRouter
    private let clothRepository: ClothRepository

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
        navigationRouter: NavigationRouter,
        clothRepository: ClothRepository
    ) {
        self.cloth = cloth
        self.navigationRouter = navigationRouter
        self.clothRepository = clothRepository
        self.imageUrl = cloth.imageUrl

        // 폼 초기화 (detail 조회 후 카테고리 정보 업데이트됨)
        self.clothForm = ClothFormData(
            name: cloth.name ?? "",
            brand: cloth.brand ?? "",
            purchaseUrl: cloth.purchaseUrl ?? "",
            category: nil,
            subcategory: nil,
            selectedSeasons: cloth.seasons
        )
    }

    // MARK: - Fetch Detail
    func fetchDetail() async {
        isFetching = true
        do {
            let detail = try await clothRepository.fetchClothDetail(clothId: cloth.id)

            // 이미지 URL 업데이트
            imageUrl = detail.clothImageUrl

            // 카테고리 업데이트 (API 응답의 이름으로 찾기)
            if let categoryName = detail.parentCategory,
               let subcategoryName = detail.category {
                if let parentCategory = CategoryConstants.all.first(where: { $0.name == categoryName }),
                   let subcategory = parentCategory.subcategories.first(where: { $0.name == subcategoryName }) {
                    clothForm.category = parentCategory
                    clothForm.subcategory = subcategory
                }
            }

            // 계절 업데이트
            if clothForm.selectedSeasons.isEmpty && !detail.seasons.isEmpty {
                clothForm.selectedSeasons = Set(detail.seasons)
            }

            // 이름, 브랜드, URL 업데이트 (기존 값이 없으면)
            if clothForm.name.isEmpty, let name = detail.name {
                clothForm.name = name
            }
            if clothForm.brand.isEmpty, let brand = detail.brand {
                clothForm.brand = brand
            }
            if clothForm.purchaseUrl.isEmpty, let url = detail.clothUrl {
                clothForm.purchaseUrl = url
            }
        } catch {
            // 에러는 무시 (기존 데이터 사용)
        }
        isFetching = false
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
        guard !isLoading else { return }
        guard let subcategory = clothForm.subcategory else {
            errorMessage = "카테고리를 선택해주세요"
            return
        }
        guard !clothForm.selectedSeasons.isEmpty else {
            errorMessage = "계절을 선택해주세요"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let request = ClothUpdateAPIRequest(
                    clothImageUrl: imageUrl,
                    clothUrl: clothForm.purchaseUrl.isEmpty ? nil : clothForm.purchaseUrl,
                    name: clothForm.name.isEmpty ? nil : clothForm.name,
                    brand: clothForm.brand.isEmpty ? nil : clothForm.brand,
                    seasons: Array(clothForm.selectedSeasons),
                    categoryId: Int64(subcategory.id)
                )

                try await clothRepository.updateCloth(clothId: cloth.id, request: request)
                isLoading = false
                navigationRouter.navigateBack()
            } catch {
                isLoading = false
                errorMessage = "수정 실패: \(error.localizedDescription)"
            }
        }
    }
}
