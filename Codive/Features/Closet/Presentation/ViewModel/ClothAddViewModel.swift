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
    @Published var aiProcessingMessage = ""

    // AI 결과 알림
    @Published var showAIResultAlert = false
    @Published var aiResultMessage = ""

    // 에러 상태
    @Published var showErrorAlert = false
    @Published var errorAlertMessage = ""

    // 유효성 검증 상태
    @Published var showValidationError = false
    @Published var categoryError = false
    @Published var seasonError = false

    // 이미지 갱신 트리거 (SwiftUI 강제 리렌더링용)
    @Published var imageRefreshId = UUID()

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

        Task { [weak self] in
            guard let self else { return }

            defer { self.isAIProcessing = false }

            let totalCount = selectedPhotos.count
            guard totalCount > 0 else { return }

            let chunkSize = 3

            aiProcessingMessage = "AI가 옷을 분석하고 배경을 제거하고 있어요 (0/\(totalCount))"

            // 1. S3 업로드 (3장씩 Data 변환 → 업로드 → 해제)
            var uploadResults: [String?] = []

            for chunkStart in stride(from: 0, to: totalCount, by: chunkSize) {
                let chunkEnd = min(chunkStart + chunkSize, totalCount)
                let chunkPhotos = Array(selectedPhotos[chunkStart..<chunkEnd])

                let chunkDatas = chunkPhotos.compactMap { $0.croppedImage.jpegData(compressionQuality: 0.8) }
                if chunkDatas.count != chunkPhotos.count {
                    uploadResults.append(contentsOf: Array(repeating: nil, count: chunkPhotos.count))
                    continue
                }

                let chunkResults = await clothAIUseCase.uploadImages(images: chunkDatas)
                uploadResults.append(contentsOf: chunkResults)
                // chunkDatas 스코프 종료 → Data 해제
            }

            let successUrls = uploadResults.compactMap { $0 }

            guard !successUrls.isEmpty else {
                errorAlertMessage = "이미지 업로드에 실패했습니다."
                showErrorAlert = true
                return
            }

            // 2. 성공한 이미지만 AI 정보 추출 (3장씩 청크 분할)
            var aiInfos: [(urlIndex: Int, info: ClothAIInfo)] = []
            for chunkStart in stride(from: 0, to: successUrls.count, by: chunkSize) {
                let chunkEnd = min(chunkStart + chunkSize, successUrls.count)
                let chunk = Array(successUrls[chunkStart..<chunkEnd])
                do {
                    let chunkInfos = try await clothAIUseCase.extractClothInfo(clothImageUrls: chunk)
                    for (i, info) in chunkInfos.enumerated() {
                        aiInfos.append((urlIndex: chunkStart + i, info: info))
                    }
                } catch {
                    #if DEBUG
                    print("[ClothAI] 정보 추출 실패 (chunk \(chunkStart/chunkSize + 1)): \(error)")
                    #endif
                }
                aiProcessingMessage = "AI가 옷을 분석하고 배경을 제거하고 있어요 (\(min(chunkEnd, totalCount))/\(totalCount))"
            }

            // 3. 결과 반영 (업로드 성공한 인덱스만)
            applyAIResults(uploadResults: uploadResults, aiInfos: aiInfos)

            // 4. 결과 메시지
            let uploadSuccessCount = successUrls.count
            var messages: [String] = []

            if uploadSuccessCount == totalCount {
                messages.append("배경 제거: \(uploadSuccessCount)장 성공")
            } else if uploadSuccessCount == 0 {
                messages.append("배경 제거: 실패")
            } else {
                let failCount = totalCount - uploadSuccessCount
                messages.append("배경 제거: \(uploadSuccessCount)장 성공, \(failCount)장 실패")
            }

            if aiInfos.isEmpty {
                messages.append("정보 추출: 실패")
            } else {
                let hasCategoryCount = aiInfos.filter { $0.info.categoryId != nil }.count
                let hasSeasonCount = aiInfos.filter { !$0.info.seasons.isEmpty }.count
                messages.append("정보 추출: 카테고리 \(hasCategoryCount)건, 계절 \(hasSeasonCount)건 자동 입력")
            }

            aiResultMessage = messages.joined(separator: "\n")
            showAIResultAlert = true
        }
    }

    private func applyAIResults(uploadResults: [String?], aiInfos: [(urlIndex: Int, info: ClothAIInfo)]) {
        // 업로드 성공한 원본 인덱스 매핑
        let successIndices = uploadResults.enumerated().compactMap { index, url in
            url != nil ? index : nil
        }

        // AI 정보 반영 (urlIndex로 정확한 위치 매핑)
        for aiEntry in aiInfos {
            guard aiEntry.urlIndex < successIndices.count else { continue }
            let originalIndex = successIndices[aiEntry.urlIndex]
            let aiInfo = aiEntry.info

            guard clothForms.indices.contains(originalIndex),
                  selectedPhotos.indices.contains(originalIndex) else { continue }

            // 누끼 이미지 URL 반영
            if !aiInfo.clothImageUrl.isEmpty {
                selectedPhotos[originalIndex].aiImageUrl = aiInfo.clothImageUrl
            }

            // 카테고리 매칭
            if let categoryId = aiInfo.categoryId,
               let subcategory = CategoryConstants.subcategory(byId: categoryId),
               let parentCategory = CategoryConstants.category(bySubcategoryId: categoryId) {
                clothForms[originalIndex].category = parentCategory
                clothForms[originalIndex].subcategory = subcategory
            } else if let parentCategoryId = aiInfo.parentCategoryId,
                      let parentCategory = CategoryConstants.category(byId: parentCategoryId) {
                clothForms[originalIndex].category = parentCategory
            }

            // 계절 반영
            if !aiInfo.seasons.isEmpty {
                clothForms[originalIndex].selectedSeasons = aiInfo.seasons
            }
        }

        currentIndex = 0
    }

    // MARK: - Eraser Editing

    func startEraserEditing() {
        guard let photo = currentPhoto else { return }

        // AI 누끼 이미지가 있으면 다운로드해서 사용
        if let aiImageUrl = photo.aiImageUrl, let url = URL(string: aiImageUrl) {
            isLoading = true
            Task { [weak self] in
                guard let self else { return }
                defer { self.isLoading = false }

                if let (data, _) = try? await URLSession.shared.data(from: url),
                   let aiImage = UIImage(data: data) {
                    var editPhoto = photo
                    editPhoto.croppedImage = aiImage
                    navigationRouter.navigate(to: .eraserEditor(photo: editPhoto, photoIndex: currentIndex))
                }
            }
        } else {
            navigationRouter.navigate(to: .eraserEditor(photo: photo, photoIndex: currentIndex))
        }
    }

    func updateErasedImage(at index: Int, image: UIImage) {
        guard selectedPhotos.indices.contains(index) else { return }
        var updated = selectedPhotos
        updated[index].croppedImage = image
        updated[index].aiImageUrl = nil
        selectedPhotos = updated
        imageRefreshId = UUID()
    }

    func dismissView() {
        navigationRouter.navigateBack()
    }

    func completeAdding() {
        guard !isLoading else { return }
        isLoading = true

        Task { [weak self] in
            guard let self else { return }
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

                // AI URL이 있는 사진과 없는 사진을 분리하여 각각 처리
                var aiInputs: [ClothInput] = []
                var aiImageUrls: [String] = []
                var normalInputs: [ClothInput] = []
                var normalImageDatas: [Data] = []

                for (index, photo) in selectedPhotos.enumerated() {
                    let input = inputs[index]
                    if isAIEnabled, let aiUrl = photo.aiImageUrl {
                        aiInputs.append(input)
                        aiImageUrls.append(aiUrl)
                    } else {
                        guard let data = photo.croppedImage.pngData() ?? photo.croppedImage.jpegData(compressionQuality: 0.8) else {
                            throw ClothAddError.imageConversionFailed
                        }
                        normalInputs.append(input)
                        normalImageDatas.append(data)
                    }
                }

                // AI URL이 있는 사진 처리
                if !aiInputs.isEmpty {
                    _ = try await clothAIUseCase.createClothesWithUrls(
                        inputs: aiInputs,
                        imageUrls: aiImageUrls
                    )
                }

                // 기존 방식 처리
                if !normalInputs.isEmpty {
                    _ = try await addClothUseCase.execute(
                        inputs: normalInputs,
                        images: normalImageDatas
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
                errorAlertMessage = "저장에 실패했습니다. 다시 시도해주세요."
                showErrorAlert = true
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
