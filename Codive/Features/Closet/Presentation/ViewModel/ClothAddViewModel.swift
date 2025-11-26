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
    var subcategory: String?
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
    func selectCategory(_ category: CategoryItem, subcategory: String)
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

    // MARK: - Dependencies
    private let navigationRouter: NavigationRouter
    private let addClothUseCase: AddClothUseCase

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
        addClothUseCase: AddClothUseCase
    ) {
        self.selectedPhotos = selectedPhotos
        self.navigationRouter = navigationRouter
        self.addClothUseCase = addClothUseCase

        // 각 사진마다 빈 폼 데이터 초기화
        self.clothForms = Array(repeating: ClothFormData(), count: selectedPhotos.count)
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
        Task {
            do {
                // UIImage → Data 변환
                let imageDatas = try selectedPhotos.map { photo -> Data in
                    guard let data = photo.croppedImage.jpegData(compressionQuality: 0.8) else {
                        throw ClothAddError.imageConversionFailed
                    }
                    return data
                }

                // ClothFormData → ClothInput 변환
                let inputs = clothForms.map { form in
                    ClothInput(
                        name: form.name,
                        brand: form.brand,
                        purchaseUrl: form.purchaseUrl,
                        categoryId: nil, // TODO: 서버 연결 시 category name → server ID 매핑 필요
                        seasons: form.selectedSeasons
                    )
                }

                // UseCase 실행
                let savedClothes = try await addClothUseCase.execute(
                    inputs: inputs,
                    images: imageDatas
                )

                // TODO: 성공 후 화면 전환
            } catch {
                // 에러 처리
                print("옷 저장 실패: \(error.localizedDescription)")
                // TODO: 에러 알럿 표시
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
