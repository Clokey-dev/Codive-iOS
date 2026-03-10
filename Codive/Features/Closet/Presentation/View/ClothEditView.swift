//
//  ClothEditView.swift
//  Codive
//
//  Created by 황상환 on 12/21/25.
//

import SwiftUI

// MARK: - ClothEditView
struct ClothEditView: View {

    // MARK: - Properties
    @StateObject private var viewModel: ClothEditViewModel

    // MARK: - Initializer
    init(viewModel: ClothEditViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            CustomNavigationBar(
                title: "옷 수정",
                onBack: {
                    viewModel.dismissView()
                },
                rightButton: .text(
                    title: TextLiteral.Common.complete,
                    isEnabled: viewModel.isFormValid
                ) {
                    viewModel.completeEditing()
                }
            )

            ScrollView {
                CustomAIRecommendationView(
                    title: "", // 타이틀 없음
                    items: [convertToClothingItem()],
                    selectedItemIndex: .constant(0),
                    onCategoryTap: {
                        viewModel.showCategorySheet()
                    },
                    onSeasonTap: {
                        viewModel.showSeasonSheet()
                    },
                    onNameChanged: { name in
                        viewModel.updateName(name)
                    },
                    onBrandChanged: { brand in
                        viewModel.updateBrand(brand)
                    },
                    onPurchaseUrlChanged: { url in
                        viewModel.updatePurchaseUrl(url)
                    },
                    showTitle: false,        // 타이틀 숨김
                    showEditButton: false    // 수정 버튼 숨김
                )
            }
            .padding(.top, 10)
        }
        .task {
            await viewModel.fetchDetail()
        }
        .navigationBarHidden(true)
        .enableSwipeBack()
        .background(Color.white)
        .sheet(isPresented: $viewModel.isCategorySheetPresented) {
            CustomCategoryBottomSheet(
                allCategories: CategoryConstants.all,
                selectedCategory: $viewModel.tempSelectedCategory,
                onApply: { category, subcategory in
                    viewModel.selectCategory(category, subcategory: subcategory)
                },
                initialSubcategory: viewModel.clothForm.subcategory
            )
            .presentationDetents([.height(404)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.isSeasonSheetPresented) {
            CustomSeasonSheet(
                initialSelected: viewModel.clothForm.selectedSeasons,
                onClose: {
                    viewModel.isSeasonSheetPresented = false
                },
                onApply: { seasons in
                    viewModel.selectSeasons(seasons)
                }
            )
            .presentationDetents([.height(358)])
            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Helper Methods
    private func convertToClothingItem() -> ClothingItem {
        let form = viewModel.clothForm

        // 봄 → 여름 → 가을 → 겨울 순서로 정렬
        let seasonText: String
        if form.selectedSeasons.isEmpty {
            seasonText = ""
        } else {
            let orderedSeasons: [Season] = [.spring, .summer, .fall, .winter]
            let sortedSeasons = orderedSeasons.filter { form.selectedSeasons.contains($0) }
            seasonText = sortedSeasons.map { $0.displayName }.joined(separator: ", ")
        }

        return ClothingItem(
            id: viewModel.cloth.id,
            imageName: nil,
            image: nil,
            imageUrl: viewModel.imageUrl,
            category: form.category?.name ?? "",
            subcategory: form.subcategory?.name ?? "",
            season: seasonText,
            name: form.name,
            brand: form.brand,
            purchaseUrl: form.purchaseUrl
        )
    }
}
