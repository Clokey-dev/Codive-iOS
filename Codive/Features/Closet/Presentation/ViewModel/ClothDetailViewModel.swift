//
//  ClothDetailViewModel.swift
//  Codive
//
//  Created by 황상환 on 12/21/25.
//

import Foundation

@MainActor
final class ClothDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    let cloth: Cloth
    @Published var showDeleteAlert: Bool = false
    @Published var showActionSheet: Bool = false
    @Published var isLoading: Bool = false
    @Published var detailData: ClothDetailResult?
    
    @Published var isOverflowMenuExpanded: Bool = false

    // MARK: - Computed Properties

    var imageUrl: String {
        detailData?.clothImageUrl ?? cloth.imageUrl
    }

    var name: String {
        detailData?.name ?? cloth.name ?? "이름 없음"
    }

    var brand: String {
        detailData?.brand ?? cloth.brand ?? "브랜드 없음"
    }

    var categoryText: String {
        // API 응답이 있으면 parentCategory > category 형식 사용
        if let detail = detailData {
            let parent = detail.parentCategory ?? ""
            let child = detail.category ?? ""
            if !parent.isEmpty && !child.isEmpty {
                return "\(parent) > \(child)"
            } else if !parent.isEmpty {
                return parent
            } else if !child.isEmpty {
                return child
            }
        }

        // fallback: cloth의 mainCategory와 subCategory 사용
        if !cloth.displayCategory.isEmpty {
            return cloth.displayCategory
        }
        return "카테고리 없음"
    }

    var seasonText: String {
        // API 상세 응답이 있으면 우선 사용
        let seasons: [Season] = detailData?.seasons ?? Array(cloth.seasons)

        if seasons.isEmpty {
            return "계절 없음"
        }

        let orderedSeasons: [Season] = [.spring, .summer, .fall, .winter]
        let selectedSeasons = orderedSeasons.filter { seasons.contains($0) }
        return selectedSeasons.map { $0.displayName }.joined(separator: ", ")
    }

    var purchaseUrl: String {
        detailData?.clothUrl ?? cloth.purchaseUrl ?? "URL 없음"
    }

    // MARK: - Private Properties

    private let navigationRouter: NavigationRouter
    private let deleteClothItemsUseCase: DeleteClothItemsUseCase
    private let clothRepository: ClothRepository

    // MARK: - Initializer

    init(
        cloth: Cloth,
        navigationRouter: NavigationRouter,
        deleteClothItemsUseCase: DeleteClothItemsUseCase,
        clothRepository: ClothRepository
    ) {
        self.cloth = cloth
        self.navigationRouter = navigationRouter
        self.deleteClothItemsUseCase = deleteClothItemsUseCase
        self.clothRepository = clothRepository
    }

    // MARK: - Fetch Detail

    func fetchDetail() async {
        isLoading = true
        do {
            let result = try await clothRepository.fetchClothDetail(clothId: cloth.id)
            detailData = result
        } catch {
            // 에러는 무시 (UI에서 기존 데이터 사용)
        }
        isLoading = false
    }

    // MARK: - Actions

    func navigateBack() {
        navigationRouter.navigateBack()
    }

    func handleMenuTap() {
        showActionSheet = true
    }

    func handleEdit() {
        isOverflowMenuExpanded = false
        navigationRouter.navigate(to: .clothEdit(cloth: cloth))
    }

    func handleDeleteRequest() {
        isOverflowMenuExpanded = false
        showDeleteAlert = true
    }

    func confirmDelete() async {
        do {
            try await deleteClothItemsUseCase.execute(clothIds: [cloth.id])
            navigationRouter.navigateBack()
        } catch {
            // TODO: 에러 메시지를 UI에 표시 (errorMessage 프로퍼티 추가 필요)
        }
    }
    
    func toggleOverflowMenu() {
        isOverflowMenuExpanded.toggle()
    }
    
    func closeOverflowMenu() {
        isOverflowMenuExpanded = false
    }
}
