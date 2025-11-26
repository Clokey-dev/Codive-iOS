//
//  ClothAddView.swift
//  Codive
//
//  Created by Claude on 11/26/25.
//

import SwiftUI

// MARK: - ClothAddView
struct ClothAddView: View {

    // MARK: - Properties
    @StateObject private var viewModel: ClothAddViewModel

    // MARK: - Initializer
    init(viewModel: ClothAddViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            CustomNavigationBar(
                title: "옷 추가",
                onBack: {
                    viewModel.dismissView()
                },
                rightButton: .text(
                    title: TextLiteral.Common.complete,
                    isEnabled: true
                ) {
                    viewModel.completeAdding()
                }
            )

            ScrollView {
                CustomAIRecommendationView(
                    title: "옷 정보를 입력해주세요",
                    items: convertToClothingItems(),
                    selectedItemIndex: $viewModel.currentIndex,
                    onCategoryTap: {
                        viewModel.showCategorySheet()
                    },
                    onSeasonTap: {
                        viewModel.showSeasonSheet()
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .sheet(isPresented: $viewModel.isCategorySheetPresented) {
            CustomCategoryBottomSheet(
                allCategories: CategoryConstants.all,
                selectedCategory: Binding(
                    get: { viewModel.currentForm.category },
                    set: { _ in }
                )
            ) { category, subcategory in
                viewModel.selectCategory(category, subcategory: subcategory)
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $viewModel.isSeasonSheetPresented) {
            CustomSeasonSheet(
                onClose: {
                    viewModel.isSeasonSheetPresented = false
                },
                onApply: { seasons in
                    viewModel.selectSeasons(seasons)
                }
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Helper Methods
    private func convertToClothingItems() -> [ClothingItem] {
        return viewModel.selectedPhotos.enumerated().map { index, photo in
            let form = viewModel.clothForms.indices.contains(index) ? viewModel.clothForms[index] : ClothFormData()

            let seasonText = form.selectedSeasons.isEmpty
                ? ""
                : form.selectedSeasons.map { $0.rawValue }.joined(separator: ", ")

            return ClothingItem(
                image: photo.croppedImage,
                category: form.category?.name ?? "",
                subcategory: form.subcategory ?? "",
                season: seasonText,
                name: form.name,
                brand: form.brand,
                purchaseUrl: form.purchaseUrl
            )
        }
    }
}
