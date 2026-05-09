//
//  FavoriteByCategoryViewModel.swift
//  Codive
//
//  Created by 황상환 on 5/3/26.
//

import Foundation
import SwiftUI

@MainActor
final class FavoriteByCategoryViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var categories: [CategoryFavoriteItem] = []
    @Published var selectedBottomSheetTitle: String = ""
    @Published var selectedBottomSheetItems: [ClothItem] = []

    /// segment 이름 → 해당 옷 목록 매핑 (탭 시 바텀시트 갱신용 캐시)
    var clothesBySegment: [String: [ClothItem]] = [:]

    /// segment 이름 → categoryId 매핑 (옷 조회 API 호출용)
    private var segmentNameToCategoryId: [String: Int64] = [:]

    func selectSegment(name: String) {
        selectedBottomSheetTitle = name

        // 캐시된 옷 목록이 있으면 즉시 표시
        if let cached = clothesBySegment[name] {
            selectedBottomSheetItems = cached
            return
        }

        // 비어있으면 로딩 상태로 표시 후 비동기 조회
        selectedBottomSheetItems = []
        guard let categoryId = segmentNameToCategoryId[name] else { return }

        Task {
            await fetchClothes(name: name, categoryId: categoryId)
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
            clothesBySegment[name] = items
            // 사용자가 그 사이 다른 segment를 선택했을 수 있으니 현재 선택 일치할 때만 업데이트
            if selectedBottomSheetTitle == name {
                selectedBottomSheetItems = items
            }
        } catch {
            #if DEBUG
            print("[FavoriteByCategory] 옷 조회 실패 - \(name)(id: \(categoryId)), error: \(error)")
            #endif
        }
    }

    // MARK: - Private Properties
    private let navigationRouter: NavigationRouter
    private let fetchFavoriteCategoryItemsUseCase: FetchFavoriteCategoryItemsUseCase
    private let clothRepository: ClothRepository
    private let parentCategoryId: Int64

    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        fetchFavoriteCategoryItemsUseCase: FetchFavoriteCategoryItemsUseCase,
        clothRepository: ClothRepository,
        parentCategoryId: Int64
    ) {
        self.navigationRouter = navigationRouter
        self.fetchFavoriteCategoryItemsUseCase = fetchFavoriteCategoryItemsUseCase
        self.clothRepository = clothRepository
        self.parentCategoryId = parentCategoryId
    }

    // MARK: - Methods
    func loadData() async {
        isLoading = true
        let colors: [Color] = [.Codive.point1, .Codive.point2, .Codive.point3, .Codive.grayscale5]

        // 진입 시 받은 부모 카테고리 1개만 조회
        let parentName = CategoryConstants.all
            .first(where: { Int64($0.id) == parentCategoryId })?.name ?? ""

        var result: [CategoryFavoriteItem] = []
        var idMapping: [String: Int64] = [:]
        do {
            let details = try await fetchFavoriteCategoryItemsUseCase.execute(
                categoryId: parentCategoryId
            )
            if !details.isEmpty {
                let segments = details.enumerated().map { index, detail in
                    if let id = detail.categoryId {
                        idMapping[detail.categoryName] = id
                    }
                    return DonutSegment(
                        value: detail.occupancyRate,
                        color: colors[min(index, colors.count - 1)],
                        payload: detail.categoryName
                    )
                }
                result.append(
                    CategoryFavoriteItem(
                        parentCategoryId: parentCategoryId,
                        categoryName: parentName,
                        items: segments
                    )
                )
            }
        } catch {
            #if DEBUG
            print("[FavoriteByCategory] \(parentName)(id: \(parentCategoryId)) 조회 실패: \(error)")
            #endif
        }
        self.categories = result
        self.segmentNameToCategoryId = idMapping
        isLoading = false
    }

    func navigateBack() {
        navigationRouter.navigateBack()
    }
}
