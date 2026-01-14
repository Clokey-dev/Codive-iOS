//
//  MyClosetSectionViewModel.swift
//  Codive
//
//  Created by 황상환 on 12/21/25.
//

import Foundation

@MainActor
final class MyClosetSectionViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var clothItems: [Cloth] = []
    @Published var isLoading: Bool = false

    // MARK: - Computed Properties
    var totalCount: Int {
        clothItems.count
    }

    // MARK: - Private Properties
    private let navigationRouter: NavigationRouter
    private let fetchMyClosetClothItemsUseCase: FetchMyClosetClothItemsUseCase

    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        fetchMyClosetClothItemsUseCase: FetchMyClosetClothItemsUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.fetchMyClosetClothItemsUseCase = fetchMyClosetClothItemsUseCase
    }

    // MARK: - Data Loading
    func loadClothItems() async {
        isLoading = true

        do {
            // 전체 옷 목록 가져오기 (필터 없음)
            let allItems = try await fetchMyClosetClothItemsUseCase.execute(
                mainCategory: nil,
                subCategory: nil,
                seasons: [],
                searchText: nil
            )

            // 최대 8개만 표시
            clothItems = Array(allItems.prefix(8))
            print("✅ [MyClosetSection] 옷 \(clothItems.count)개 로드 완료")
        } catch {
            print("❌ [MyClosetSection] 옷 로딩 실패: \(error)")
        }

        isLoading = false
    }

    // MARK: - Navigation
    func navigateToMyCloset() {
        navigationRouter.navigate(to: .myCloset)
    }

    func navigateToClothDetail(_ cloth: Cloth) {
        navigationRouter.navigate(to: .clothDetail(cloth: cloth))
    }
}
