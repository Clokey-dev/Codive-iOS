//
//  MyClosetViewModel.swift
//  Codive
//
//  Created by 황상환 on 12/21/25.
//

import Foundation
import Combine

@MainActor
final class MyClosetViewModel: ObservableObject {

    // MARK: - Published Properties

    // 데이터 관련
    @Published var clothItems: [Cloth] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // 필터 관련
    @Published var searchText: String = ""
    @Published var selectedMainCategory: String = "전체"
    @Published var selectedSubCategory: String = ""
    @Published var selectedSeasons: Set<Season> = []

    // 편집 모드 관련
    @Published var isEditMode: Bool = false
    @Published var selectedItemIds: Set<Int> = []

    // MARK: - Computed Properties

    var totalCount: Int {
        clothItems.count
    }

    var isDeleteEnabled: Bool {
        !selectedItemIds.isEmpty
    }

    // MARK: - Private Properties

    private let navigationRouter: NavigationRouter
    private let fetchMyClosetClothItemsUseCase: FetchMyClosetClothItemsUseCase
    private let deleteClothItemsUseCase: DeleteClothItemsUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    init(
        navigationRouter: NavigationRouter,
        fetchMyClosetClothItemsUseCase: FetchMyClosetClothItemsUseCase,
        deleteClothItemsUseCase: DeleteClothItemsUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.fetchMyClosetClothItemsUseCase = fetchMyClosetClothItemsUseCase
        self.deleteClothItemsUseCase = deleteClothItemsUseCase

        setupFilterObservers()
    }

    // MARK: - Setup

    private func setupFilterObservers() {
        // 필터 변경 시 자동으로 데이터 로드
        Publishers.CombineLatest4(
            $searchText.debounce(for: 0.5, scheduler: DispatchQueue.main),
            $selectedMainCategory,
            $selectedSubCategory,
            $selectedSeasons
        )
        .dropFirst() // 초기 값 무시
        .sink { [weak self] _ in
            Task {
                await self?.loadClothItems()
            }
        }
        .store(in: &cancellables)
    }

    // MARK: - Data Loading

    func loadClothItems() async {
        isLoading = true
        errorMessage = nil

        do {
            clothItems = try await fetchMyClosetClothItemsUseCase.execute(
                mainCategory: selectedMainCategory,
                subCategory: selectedSubCategory.isEmpty ? nil : selectedSubCategory,
                seasons: selectedSeasons,
                searchText: searchText.isEmpty ? nil : searchText
            )
        } catch {
            errorMessage = "옷 목록을 불러오는데 실패했습니다."
            print("Error loading cloth items: \(error)")
        }

        isLoading = false
    }

    // MARK: - Actions

    func toggleEditMode() {
        isEditMode.toggle()
        if !isEditMode {
            selectedItemIds.removeAll()
        }
    }

    func toggleItemSelection(_ id: Int) {
        if selectedItemIds.contains(id) {
            selectedItemIds.remove(id)
        } else {
            selectedItemIds.insert(id)
        }
    }

    func deleteSelectedItems() async {
        guard !selectedItemIds.isEmpty else { return }

        let idsToDelete = Array(selectedItemIds)

        do {
            try await deleteClothItemsUseCase.execute(clothIds: idsToDelete)

            // 삭제 성공 시 로컬 데이터에서 제거
            clothItems.removeAll { selectedItemIds.contains($0.id) }

            // 편집 모드 종료
            isEditMode = false
            selectedItemIds.removeAll()
        } catch {
            errorMessage = "옷 삭제에 실패했습니다."
            print("Error deleting cloth items: \(error)")
        }
    }

    func updateMainCategory(_ category: String) {
        selectedMainCategory = category
        // 메인 카테고리 변경 시 서브 카테고리 선택 초기화 (전체 보기)
        selectedSubCategory = ""
    }

    func updateSubCategory(_ subCategory: String) {
        selectedSubCategory = subCategory
    }

    func updateSeasons(_ seasons: Set<Season>) {
        selectedSeasons = seasons
    }

    func navigateBack() {
        // 편집 모드이면 먼저 편집 모드 종료
        if isEditMode {
            isEditMode = false
            selectedItemIds.removeAll()
        } else {
            navigationRouter.navigateBack()
        }
    }

    func navigateToClothDetail(_ cloth: Cloth) {
        navigationRouter.navigate(to: .clothDetail(cloth: cloth))
    }

    func navigateToAddCloth() {
        navigationRouter.navigate(to: .clothPhotoSelect)
    }
}
