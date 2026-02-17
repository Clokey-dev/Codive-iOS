//
//  ClothAddViewModel.swift
//  Codive
//
//  Created by 황상환 on 11/26/25.
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
    var subcategory: SubcategoryItem?
    var selectedSeasons: Set<Season> = []
}

// MARK: - ClothAddViewModelInput
@MainActor
protocol ClothAddViewModelInput {
    func updateName(_ name: String)
    func updateBrand(_ brand: String)
    func updatePurchaseUrl(_ url: String)
    func showCategorySheet()
    func showSeasonSheet()
    func selectCategory(_ category: CategoryItem, subcategory: SubcategoryItem)
    func selectSeasons(_ seasons: Set<Season>)
    func moveToPrevious()
    func moveToNext()
    func dismissView()
    func completeAdding()
}

// MARK: - ClothAddViewModelOutput
@MainActor
protocol ClothAddViewModelOutput {
    var selectedPhotos: [SelectedPhoto] { get }
    var currentIndex: Int { get }
    var clothForms: [ClothFormData] { get }
    var isCategorySheetPresented: Bool { get set }
    var isSeasonSheetPresented: Bool { get set }
    var tempSelectedCategory: CategoryItem? { get set }

    var currentPhoto: SelectedPhoto? { get }
    var currentForm: ClothFormData { get }
    var categoryDisplayText: String { get }
    var seasonDisplayText: String { get }
    var isCurrentFormValid: Bool { get }
    var isAllFormsValid: Bool { get }
    var isFirstPhoto: Bool { get }
    var isLastPhoto: Bool { get }
    var isSinglePhoto: Bool { get }
}

// MARK: - ClothAddViewModel
@MainActor
final class ClothAddViewModel: ObservableObject, ClothAddViewModelInput, ClothAddViewModelOutput {

    // MARK: - Output Properties
    @Published var selectedPhotos: [SelectedPhoto]
    @Published var currentIndex: Int = 0
    @Published var clothForms: [ClothFormData] = []

    // Sheet states
    @Published var isCategorySheetPresented = false
    @Published var isSeasonSheetPresented = false
    @Published var tempSelectedCategory: CategoryItem?

    // 완료 상태
    @Published var isLoading = false
    @Published var isAIProcessing = false

    // AI 결과 알림
    @Published var showAIResultAlert = false
    @Published var aiResultMessage = ""

    // 유효성 검증 상태
    @Published var showValidationError = false
    @Published var categoryError = false
    @Published var seasonError = false

    // MARK: - Dependencies
    private let navigationRouter: NavigationRouter
    private let addClothUseCase: AddClothUseCase
    private let clothAIUseCase: ClothAIUseCase
    let isAIEnabled: Bool

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
            return "\(category.name) > \(subcategory.name)"
        }
        return ""
    }

    var seasonDisplayText: String {
        if currentForm.selectedSeasons.isEmpty {
            return ""
        }
        // 봄 → 여름 → 가을 → 겨울 순서로 정렬
        let orderedSeasons: [Season] = [.spring, .summer, .fall, .winter]
        let sortedSeasons = orderedSeasons.filter { currentForm.selectedSeasons.contains($0) }
        return sortedSeasons.map { $0.displayName }.joined(separator: ", ")
    }

    var isCurrentFormValid: Bool {
        return currentForm.category != nil && !currentForm.selectedSeasons.isEmpty
    }

    var isAllFormsValid: Bool {
        return clothForms.allSatisfy { form in
            form.category != nil && !form.selectedSeasons.isEmpty
        }
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
        navigationRouter: NavigationRouter,
        addClothUseCase: AddClothUseCase,
        clothAIUseCase: ClothAIUseCase,
        isAIEnabled: Bool = false
    ) {
        self.selectedPhotos = selectedPhotos
        self.navigationRouter = navigationRouter
        self.addClothUseCase = addClothUseCase
        self.clothAIUseCase = clothAIUseCase
        self.isAIEnabled = isAIEnabled

        // 각 사진마다 빈 폼 데이터 초기화
        self.clothForms = Array(repeating: ClothFormData(), count: selectedPhotos.count)

        if isAIEnabled {
            processAI()
        }
    }

    // MARK: - Input Methods

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

    func selectCategory(_ category: CategoryItem, subcategory: SubcategoryItem) {
        clothForms[currentIndex].category = category
        clothForms[currentIndex].subcategory = subcategory
        categoryError = false
        isCategorySheetPresented = false
    }

    func selectSeasons(_ seasons: Set<Season>) {
        clothForms[currentIndex].selectedSeasons = seasons
        seasonError = false
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

    var completedItemIndices: Set<Int> {
        Set(clothForms.indices.filter { index in
            clothForms[index].category != nil && !clothForms[index].selectedSeasons.isEmpty
        })
    }

    func trySelectItem(at index: Int) {
        guard index != currentIndex else { return }

        // 이미 완료된 아이템으로의 이동은 자유롭게 허용
        let targetForm = clothForms[index]
        let isTargetCompleted = targetForm.category != nil && !targetForm.selectedSeasons.isEmpty
        if isTargetCompleted {
            clearValidationErrors()
            currentIndex = index
            return
        }

        // 새로운(미완료) 아이템으로 이동 시 현재 아이템 유효성 검증
        let form = clothForms[currentIndex]
        let isCategoryMissing = form.category == nil
        let isSeasonMissing = form.selectedSeasons.isEmpty

        if isCategoryMissing || isSeasonMissing {
            categoryError = isCategoryMissing
            seasonError = isSeasonMissing
            showValidationError = true
            return
        }

        clearValidationErrors()
        currentIndex = index
    }

    func clearValidationErrors() {
        categoryError = false
        seasonError = false
        showValidationError = false
    }

    // MARK: - AI Processing

    func processAI() {
        isAIProcessing = true

        Task {
            do {
                let imageDatas = selectedPhotos.compactMap { $0.croppedImage.jpegData(compressionQuality: 0.8) }
                guard !imageDatas.isEmpty else {
                    isAIProcessing = false
                    return
                }

                let imageUrls = try await clothAIUseCase.uploadImages(images: imageDatas)
                guard !imageUrls.isEmpty else {
                    isAIProcessing = false
                    return
                }

                var aiInfos: [ClothAIInfo] = []
                do {
                    aiInfos = try await clothAIUseCase.extractClothInfo(clothImageUrls: imageUrls)
                } catch { }

                applyAIResults(imageUrls: imageUrls, aiInfos: aiInfos)

                let totalCount = selectedPhotos.count
                let imageSuccessCount = selectedPhotos.filter { $0.aiImageUrl != nil }.count

                var messages: [String] = []

                if imageSuccessCount == totalCount {
                    messages.append("배경 제거: \(imageSuccessCount)장 성공")
                } else if imageSuccessCount == 0 {
                    messages.append("배경 제거: 실패")
                } else {
                    let failCount = totalCount - imageSuccessCount
                    messages.append("배경 제거: \(imageSuccessCount)장 성공, \(failCount)장 실패")
                }

                if aiInfos.isEmpty {
                    messages.append("정보 추출: 실패")
                } else {
                    let hasCategoryCount = aiInfos.filter { $0.categoryId != nil }.count
                    let hasSeasonCount = aiInfos.filter { !$0.seasons.isEmpty }.count
                    messages.append("정보 추출: 카테고리 \(hasCategoryCount)건, 계절 \(hasSeasonCount)건 자동 입력")
                }

                aiResultMessage = messages.joined(separator: "\n")
                showAIResultAlert = true

                isAIProcessing = false
            } catch {
                isAIProcessing = false
            }
        }
    }

    private func applyAIResults(imageUrls: [String], aiInfos: [ClothAIInfo]) {
        let resultCount = aiInfos.count
        guard resultCount > 0 else { return }

        // AI 정보 반영
        for (index, aiInfo) in aiInfos.enumerated() {
            guard clothForms.indices.contains(index),
                  selectedPhotos.indices.contains(index) else { continue }

            // 누끼 이미지 URL 반영
            if !aiInfo.clothImageUrl.isEmpty {
                selectedPhotos[index].aiImageUrl = aiInfo.clothImageUrl
            }

            // 카테고리 매칭
            if let categoryId = aiInfo.categoryId,
               let subcategory = CategoryConstants.subcategory(byId: categoryId),
               let parentCategory = CategoryConstants.category(bySubcategoryId: categoryId) {
                clothForms[index].category = parentCategory
                clothForms[index].subcategory = subcategory
            } else if let parentCategoryId = aiInfo.parentCategoryId,
                      let parentCategory = CategoryConstants.category(byId: parentCategoryId) {
                clothForms[index].category = parentCategory
            }

            // 계절 반영
            if !aiInfo.seasons.isEmpty {
                clothForms[index].selectedSeasons = aiInfo.seasons
            }
        }

        currentIndex = 0
    }

    func dismissView() {
        navigationRouter.navigateBack()
    }

    func completeAdding() {
        guard !isLoading else { return }
        isLoading = true

        Task {
            do {
                // ClothFormData → ClothInput 변환
                let inputs = clothForms.map { form in
                    ClothInput(
                        name: form.name,
                        brand: form.brand,
                        purchaseUrl: form.purchaseUrl,
                        categoryId: form.subcategory?.id,
                        seasons: form.selectedSeasons
                    )
                }

                // AI 이미지 URL이 있으면 재업로드 없이 바로 저장
                let hasAIImages = selectedPhotos.contains { $0.aiImageUrl != nil }
                if isAIEnabled && hasAIImages {
                    let imageUrls = selectedPhotos.map { $0.aiImageUrl ?? "" }
                    _ = try await clothAIUseCase.createClothesWithUrls(
                        inputs: inputs,
                        imageUrls: imageUrls
                    )
                } else {
                    // 기존 방식: UIImage → Data 변환 후 업로드
                    let imageDatas = try selectedPhotos.map { photo -> Data in
                        guard let data = photo.croppedImage.jpegData(compressionQuality: 0.8) else {
                            throw ClothAddError.imageConversionFailed
                        }
                        return data
                    }
                    _ = try await addClothUseCase.execute(
                        inputs: inputs,
                        images: imageDatas
                    )
                }

                isLoading = false
                navigationRouter.showSuccessAndNavigate(
                    message: "옷장에 옷을 보관했어요!",
                    to: .closet,
                    destination: .myCloset,
                    duration: 1.5
                )
            } catch {
                isLoading = false
            }
        }
    }
}

// MARK: - ClothAddError
enum ClothAddError: LocalizedError {
    case imageConversionFailed

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "이미지 변환에 실패했습니다."
        }
    }
}
