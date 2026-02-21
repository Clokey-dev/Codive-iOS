//
//  ClothAddView.swift
//  Codive
//
//  Created by 황상환 on 11/26/25.
//

import SwiftUI

// MARK: - ClothAddView
struct ClothAddView: View {

    // MARK: - Properties
    /// ViewModel (Input: 액션 전달, Output: 상태 관찰)
    @StateObject private var viewModel: ClothAddViewModel

    // MARK: - Initializer
    init(viewModel: ClothAddViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // 메인 콘텐츠
            VStack(spacing: 0) {
                // Navigation Bar
                CustomNavigationBar(
                    title: TextLiteral.Closet.clothAddTitle,
                    onBack: {
                        viewModel.dismissView()
                    },
                    rightButton: .text(
                        title: TextLiteral.Common.complete,
                        isEnabled: viewModel.isAllFormsValid && !viewModel.isLoading && !viewModel.isAIProcessing
                    ) {
                        viewModel.completeAdding()
                    }
                )

                ScrollView {
                    CustomAIRecommendationView(
                        title: TextLiteral.Closet.clothLoadedTitle,
                        items: convertToClothingItems(),
                        selectedItemIndex: $viewModel.currentIndex,
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
                        showCategoryError: viewModel.categoryError,
                        showSeasonError: viewModel.seasonError,
                        completedItemIndices: viewModel.completedItemIndices,
                        onThumbnailTap: { index in
                            viewModel.trySelectItem(at: index)
                        }
                    )
                }
                .padding(.top, 10)
            }

            // 로딩 인디케이터
            if viewModel.isLoading || viewModel.isAIProcessing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    if viewModel.isAIProcessing {
                        if viewModel.aiTotalCount > 1 {
                            Text("AI가 옷을 분석하고 있어요 (\(viewModel.aiProcessedCount)/\(viewModel.aiTotalCount))")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        } else {
                            Text("AI가 옷을 분석하고 있어요")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .enableSwipeBack()
        .background(Color.white)
        .customToast(
            isPresented: $viewModel.showValidationError,
            message: "필수정보를 모두 입력해주세요"
        )
        .alert("AI 분석 결과", isPresented: $viewModel.showAIResultAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.aiResultMessage)
        }
        .alert("오류", isPresented: $viewModel.showErrorAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorAlertMessage)
        }
        .sheet(isPresented: $viewModel.isCategorySheetPresented) {
            CustomCategoryBottomSheet(
                allCategories: CategoryConstants.all,
                selectedCategory: $viewModel.tempSelectedCategory,
                onApply: { category, subcategory in
                    viewModel.selectCategory(category, subcategory: subcategory)
                },
                initialSubcategory: viewModel.currentForm.subcategory
            )
            .presentationDetents([.height(404)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.isSeasonSheetPresented) {
            CustomSeasonSheet(
                initialSelected: viewModel.currentForm.selectedSeasons,
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
    private func convertToClothingItems() -> [ClothingItem] {
        return viewModel.selectedPhotos.enumerated().map { index, photo in
            let form = viewModel.clothForms.indices.contains(index) ? viewModel.clothForms[index] : ClothFormData()

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
                id: index,
                imageName: nil,
                image: photo.aiImageUrl == nil ? photo.croppedImage : nil,
                imageUrl: photo.aiImageUrl,
                category: form.category?.name ?? "",
                subcategory: form.subcategory?.name ?? "",
                season: seasonText,
                name: form.name,
                brand: form.brand,
                purchaseUrl: form.purchaseUrl
            )
        }
    }
}
