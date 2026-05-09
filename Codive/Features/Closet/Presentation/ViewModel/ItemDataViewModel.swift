//
//  ItemDataViewModel.swift
//  Codive
//
//  Created by 황상환 on 5/3/26.
//

import Foundation

@MainActor
final class ItemDataViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var stats: [ItemUsageStat] = []
    @Published var selectedIndex: Int?
    @Published var selectedBottomSheetTitle: String = ""
    @Published var selectedBottomSheetItems: [ClothItem] = []

    /// 아이템 이름 → 옷 목록 매핑 (탭 시 바텀시트 갱신용 캐시)
    var clothesByItem: [String: [ClothItem]] = [:]

    /// 아이템 이름 → categoryId 매핑 (옷 조회 API 호출용)
    private var itemNameToCategoryId: [String: Int64] = [:]

    // MARK: - Private Properties
    private let navigationRouter: NavigationRouter
    private let fetchFavoriteItemsUseCase: FetchFavoriteItemsUseCase
    private let clothRepository: ClothRepository

    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        fetchFavoriteItemsUseCase: FetchFavoriteItemsUseCase,
        clothRepository: ClothRepository
    ) {
        self.navigationRouter = navigationRouter
        self.fetchFavoriteItemsUseCase = fetchFavoriteItemsUseCase
        self.clothRepository = clothRepository
    }

    // MARK: - Methods
    func loadData() async {
        isLoading = true
        do {
            let items = try await fetchFavoriteItemsUseCase.execute()
            self.stats = items.map {
                ItemUsageStat(itemName: $0.categoryName, usageCount: $0.clothCount)
            }
            self.itemNameToCategoryId = items.reduce(into: [String: Int64]()) { dict, payload in
                if let id = payload.categoryId {
                    dict[payload.categoryName] = id
                }
            }
            if !stats.isEmpty {
                selectBar(at: 0)
            }
        } catch {
            #if DEBUG
            print("[ItemData] 데이터 로드 실패: \(error)")
            #endif
        }
        isLoading = false
    }

    func selectBar(at index: Int) {
        selectedIndex = index
        guard stats.indices.contains(index) else { return }
        let item = stats[index]
        selectedBottomSheetTitle = item.itemName

        // 캐시된 옷 목록이 있으면 즉시 표시
        if let cached = clothesByItem[item.itemName] {
            selectedBottomSheetItems = cached
            return
        }

        // 비어있으면 로딩 상태로 표시 후 비동기 조회
        selectedBottomSheetItems = []
        guard let categoryId = itemNameToCategoryId[item.itemName] else { return }

        Task {
            await fetchClothes(name: item.itemName, categoryId: categoryId)
        }
    }

    private func fetchClothes(name: String, categoryId: Int64) async {
        do {
            let result = try await clothRepository.fetchClothList(
                lastClothId: nil,
                size: 50,
                categoryId: Int(categoryId),
                seasons: []
            )
            let items = result.clothes.map { ClothItem(from: $0) }
            clothesByItem[name] = items
            if selectedBottomSheetTitle == name {
                selectedBottomSheetItems = items
            }
        } catch {
            #if DEBUG
            print("[ItemData] 옷 조회 실패 - \(name)(id: \(categoryId)), error: \(error)")
            #endif
        }
    }

    func navigateBack() {
        navigationRouter.navigateBack()
    }
}
