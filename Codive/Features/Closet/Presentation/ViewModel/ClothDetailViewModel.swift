//
//  ClothDetailViewModel.swift
//  Codive
//
//  Created by Claude on 12/21/25.
//

import Foundation

@MainActor
final class ClothDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    let cloth: Cloth
    @Published var showDeleteAlert: Bool = false
    @Published var showActionSheet: Bool = false

    // MARK: - Computed Properties

    var imageUrl: String {
        cloth.imageUrl
    }

    var name: String {
        cloth.name ?? "이름 없음"
    }

    var brand: String {
        cloth.brand ?? "브랜드 없음"
    }

    var categoryText: String {
        guard let categoryId = cloth.categoryId else {
            return "카테고리 없음"
        }

        // categoryId는 1부터 시작 (배열 인덱스는 0부터)
        let categoryIndex = categoryId - 1
        guard categoryIndex >= 0 && categoryIndex < CategoryConstants.all.count else {
            return "카테고리 없음"
        }

        let category = CategoryConstants.all[categoryIndex]
        return category.name
        // TODO: 서브 카테고리 추가되면 "상의 > 티셔츠" 형식으로 변경
    }

    var seasonText: String {
        if cloth.seasons.isEmpty {
            return "계절 없음"
        }

        let orderedSeasons: [Season] = [.spring, .summer, .fall, .winter]
        let selectedSeasons = orderedSeasons.filter { cloth.seasons.contains($0) }
        return selectedSeasons.map { $0.displayName }.joined(separator: ", ")
    }

    var purchaseUrl: String {
        cloth.purchaseUrl ?? "URL 없음"
    }

    // MARK: - Private Properties

    private let navigationRouter: NavigationRouter
    private let deleteClothItemsUseCase: DeleteClothItemsUseCase

    // MARK: - Initializer

    init(
        cloth: Cloth,
        navigationRouter: NavigationRouter,
        deleteClothItemsUseCase: DeleteClothItemsUseCase
    ) {
        self.cloth = cloth
        self.navigationRouter = navigationRouter
        self.deleteClothItemsUseCase = deleteClothItemsUseCase
    }

    // MARK: - Actions

    func navigateBack() {
        navigationRouter.navigateBack()
    }

    func handleMenuTap() {
        showActionSheet = true
    }

    func handleEdit() {
        navigationRouter.navigate(to: .clothEdit(cloth: cloth))
    }

    func handleDeleteRequest() {
        showActionSheet = false
        showDeleteAlert = true
    }

    func confirmDelete() async {
        do {
            try await deleteClothItemsUseCase.execute(clothIds: [cloth.id])
            // 삭제 성공 시 뒤로가기
            navigationRouter.navigateBack()
        } catch {
            // TODO: 에러 처리
            print("삭제 실패: \(error)")
        }
    }
}
