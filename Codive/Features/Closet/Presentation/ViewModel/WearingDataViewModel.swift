//
//  WearingDataViewModel.swift
//  Codive
//
//  Created by 황상환 on 5/3/26.
//

import Foundation

@MainActor
final class WearingDataViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var stats: WardrobeUsageStat = WardrobeUsageStat(totalCount: 0, wornCount: 0)
    @Published var utilizedClothes: [ClothItem] = []
    @Published var unutilizedClothes: [ClothItem] = []
    @Published var selectedBottomSheetTitle: String = ""
    @Published var selectedBottomSheetItems: [ClothItem] = []
    /// "입음" 또는 "미착용" — 강조된 segment 추적
    @Published var selectedPayload: String = "입음"

    var seasonLabel: String { Season.current.displayName }

    /// 강조된 segment에 따라 부제 동적 변경
    var subtitleText: String {
        let notWorn = max(0, stats.totalCount - stats.wornCount)
        if selectedPayload == "미착용" {
            return "아직 못 입은 \(seasonLabel) 옷이 \(notWorn)벌 있어요\n그래프를 눌러 확인해보세요!"
        }
        return "보관 중인 \(seasonLabel) 옷 \(stats.totalCount)벌 중\n\(stats.wornCount)벌을 실제로 입었어요"
    }

    /// 도넛 가운데 % 텍스트 — 강조된 segment의 비율
    var centerPercent: Int {
        guard stats.totalCount > 0 else { return 0 }
        if selectedPayload == "미착용" {
            let notWorn = max(0, stats.totalCount - stats.wornCount)
            return Int(round(Double(notWorn) / Double(stats.totalCount) * 100))
        }
        return stats.usagePercent
    }

    func selectSegment(payload: String) {
        selectedPayload = payload
        let notWorn = max(0, stats.totalCount - stats.wornCount)
        if payload == "입음" {
            selectedBottomSheetTitle = "\(stats.wornCount)벌 착용"
            selectedBottomSheetItems = utilizedClothes
        } else if payload == "미착용" {
            selectedBottomSheetTitle = "\(notWorn)벌 미착용"
            selectedBottomSheetItems = unutilizedClothes
        }
    }

    // MARK: - Private Properties
    private let navigationRouter: NavigationRouter
    private let fetchClosetUtilizationUseCase: FetchClosetUtilizationUseCase

    private var currentSeason: String { Season.current.rawValue }

    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        fetchClosetUtilizationUseCase: FetchClosetUtilizationUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.fetchClosetUtilizationUseCase = fetchClosetUtilizationUseCase
    }

    // MARK: - Methods
    func loadData() async {
        isLoading = true
        do {
            let result = try await fetchClosetUtilizationUseCase.execute(season: currentSeason)
            self.stats = WardrobeUsageStat(
                totalCount: result.utilizedCount + result.unutilizedCount,
                wornCount: result.utilizedCount
            )
            self.utilizedClothes = result.utilizedClothes.map {
                ClothItem(imageUrl: $0.imageUrl, brand: $0.brand, name: $0.name)
            }
            self.unutilizedClothes = result.unutilizedClothes.map {
                ClothItem(imageUrl: $0.imageUrl, brand: $0.brand, name: $0.name)
            }
            // 첫 진입 시 입음 자동 강조
            selectSegment(payload: "입음")
        } catch {
            #if DEBUG
            print("[WearingData] 데이터 로드 실패: \(error)")
            #endif
        }
        isLoading = false
    }

    func navigateBack() {
        navigationRouter.navigateBack()
    }
}
