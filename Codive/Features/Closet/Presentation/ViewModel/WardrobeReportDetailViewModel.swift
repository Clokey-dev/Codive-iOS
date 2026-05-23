//
//  WardrobeReportDetailViewModel.swift
//  Codive
//
//  Created by 황상환 on 2/26/26.
//

import Foundation
import SwiftUI

@MainActor
final class WardrobeReportDetailViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var canAggregate: Bool = false
    @Published var isShowingNetworkErrorAlert: Bool = false
    @Published var networkErrorMessage: String?

    // 통계 데이터
    @Published var favoriteItems: [ItemUsageStat] = []
    @Published var favoriteCategories: [CategoryFavoriteItem] = []
    @Published var wardrobeUsage: WardrobeUsageStat = WardrobeUsageStat(totalCount: 0, wornCount: 0)
    /// 활용도 체크 카드의 부제에 표시할 가장 많이 입은 옷 이름
    @Published var topUtilizedItemName: String?

    // MARK: - Computed Properties
    var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }

    var dateRangeString: String {
        let now = Date()
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return "\(formatter.string(from: oneMonthAgo)) ~ \(formatter.string(from: now))"
    }

    var currentSeason: String {
        Season.current.rawValue
    }

    // MARK: - Private Properties
    private let navigationRouter: NavigationRouter
    private let checkStatisticsConditionUseCase: CheckStatisticsConditionUseCase
    private let fetchFavoriteItemsUseCase: FetchFavoriteItemsUseCase
    private let fetchFavoriteCategoryItemsUseCase: FetchFavoriteCategoryItemsUseCase
    private let fetchClosetUtilizationUseCase: FetchClosetUtilizationUseCase

    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        checkStatisticsConditionUseCase: CheckStatisticsConditionUseCase,
        fetchFavoriteItemsUseCase: FetchFavoriteItemsUseCase,
        fetchFavoriteCategoryItemsUseCase: FetchFavoriteCategoryItemsUseCase,
        fetchClosetUtilizationUseCase: FetchClosetUtilizationUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.checkStatisticsConditionUseCase = checkStatisticsConditionUseCase
        self.fetchFavoriteItemsUseCase = fetchFavoriteItemsUseCase
        self.fetchFavoriteCategoryItemsUseCase = fetchFavoriteCategoryItemsUseCase
        self.fetchClosetUtilizationUseCase = fetchClosetUtilizationUseCase
    }

    // MARK: - Methods

    func loadReport() async {
        isLoading = true
        do {
            canAggregate = try await checkStatisticsConditionUseCase.execute()
            if canAggregate {
                await fetchAllStatistics()
            }
        } catch {
            canAggregate = false
            networkErrorMessage = "네트워크 오류가 발생했습니다. 다시 시도해주세요."
            isShowingNetworkErrorAlert = true
            #if DEBUG
            print("[WardrobeReport] 통계 조건 확인 실패: \(error)")
            #endif
        }
        isLoading = false
    }

    private func fetchAllStatistics() async {
        // 아이템 통계 & 활용도를 병렬로 가져오기
        async let itemsTask = fetchFavoriteItemsUseCase.execute()
        async let utilizationTask = fetchClosetUtilizationUseCase.execute(season: currentSeason)

        do {
            let items = try await itemsTask
            self.favoriteItems = items.map {
                ItemUsageStat(itemName: $0.categoryName, usageCount: $0.clothCount)
            }

            // 카테고리별 상세 데이터를 가져오기 (1차 카테고리 기준)
            await fetchCategoryDetails()
        } catch {
            #if DEBUG
            print("[WardrobeReport] 아이템 통계 조회 실패: \(error)")
            #endif
        }

        do {
            let utilization = try await utilizationTask
            self.wardrobeUsage = WardrobeUsageStat(
                totalCount: utilization.utilizedCount + utilization.unutilizedCount,
                wornCount: utilization.utilizedCount
            )
            self.topUtilizedItemName = utilization.utilizedClothes.first?.name
        } catch {
            #if DEBUG
            print("[WardrobeReport] 활용도 조회 실패: \(error)")
            #endif
        }
    }

    private func fetchCategoryDetails() async {
        var categories: [CategoryFavoriteItem] = []
        let colors: [Color] = [.Codive.point1, .Codive.point2, .Codive.point3, .Codive.grayscale5]

        // 1차 카테고리(상의, 바지, 스커트 등) 기준으로 조회
        for parentCategory in CategoryConstants.all {
            do {
                let details = try await fetchFavoriteCategoryItemsUseCase.execute(
                    categoryId: Int64(parentCategory.id)
                )
                guard !details.isEmpty else { continue }
                let segments = details.enumerated().map { index, detail in
                    DonutSegment(
                        value: detail.occupancyRate,
                        color: colors[min(index, colors.count - 1)],
                        payload: detail.categoryName
                    )
                }
                categories.append(
                    CategoryFavoriteItem(
                        parentCategoryId: Int64(parentCategory.id),
                        categoryName: parentCategory.name,
                        items: segments
                    )
                )
            } catch {
                #if DEBUG
                print("[WardrobeReport] 카테고리 상세 조회 실패 - \(parentCategory.name)(id: \(parentCategory.id)), error: \(error)")
                #endif
            }
        }
        self.favoriteCategories = categories
    }

    // MARK: - Navigation

    func navigateBack() {
        navigationRouter.navigateBack()
    }

    func navigateToRecordAdd() {
        navigationRouter.navigate(to: .recordAdd())
    }

    func navigateToFavoriteCategory(parentCategoryId: Int64) {
        navigationRouter.navigate(to: .wardrobeFavoriteCategory(parentCategoryId: parentCategoryId))
    }

    func navigateToItemStats() {
        navigationRouter.navigate(to: .wardrobeItemStats)
    }

    func navigateToUsageCheck() {
        navigationRouter.navigate(to: .wardrobeUsageCheck)
    }
}
