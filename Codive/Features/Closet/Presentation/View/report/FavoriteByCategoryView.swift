//
//  FavoriteByCategoryView.swift
//  Codive
//
//  Created by 한태빈 on 12/19/25.
//

import Foundation
import SwiftUI

struct FavoriteByCategoryView: View {

    @StateObject private var viewModel: FavoriteByCategoryViewModel
    @State private var isExpanded: Bool = false

    private let collapsedHeight: CGFloat = 420

    init(viewModel: FavoriteByCategoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // 메인 콘텐츠 (도넛은 상단에)
                VStack(spacing: 0) {
                    CustomNavigationBar(title: "카테고리 통계") {
                        viewModel.navigateBack()
                    }
                    .background(Color.white)

                    Text("그래프를 눌러 구체적인 히스토리를 살펴보세요")
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale3)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .frame(maxWidth: .infinity)
                        Spacer()
                    } else if let firstCategory = viewModel.categories.first {
                        CategoryDonutSection(
                            item: firstCategory,
                            onSelectSegment: { segmentName, _ in
                                viewModel.selectSegment(name: segmentName)
                            }
                        )
                        .padding(.top, 16)
                        Spacer(minLength: 0)
                        // 바텀시트 영역만큼 빈 공간 확보
                        Color.clear.frame(height: collapsedHeight - 60)
                    } else {
                        Spacer()
                    }
                }

                // 바텀시트 (페이지 하단에 고정)
                DataBottomSheet(
                    title: viewModel.selectedBottomSheetTitle,
                    totalCount: viewModel.selectedBottomSheetItems.count,
                    items: viewModel.selectedBottomSheetItems
                )
                .frame(
                    width: geometry.size.width,
                    height: isExpanded ? geometry.size.height * 0.75 : collapsedHeight
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -4)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            withAnimation(.spring()) {
                                if value.translation.height < -50 {
                                    isExpanded = true
                                } else if value.translation.height > 50 {
                                    isExpanded = false
                                }
                            }
                        }
                )
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .background(Color.white)
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await viewModel.loadData()
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

// MARK: - CategoryDonutSection

private struct CategoryDonutSection: View {
    let item: CategoryFavoriteItem
    var onSelectSegment: (String, [ClothItem]) -> Void

    @State private var selectedID: DonutSegment.ID?

    private var total: Double {
        item.items.map(\.value).reduce(0, +)
    }

    private var selectedSegment: DonutSegment? {
        guard let selectedID else { return nil }
        return item.items.first(where: { $0.id == selectedID })
    }

    private var selectedPercent: Int {
        guard let seg = selectedSegment, total > 0 else { return 0 }
        return Int(round((seg.value / total) * 100))
    }

    /// 강조된 segment의 가운데 각도에 맞춰 말풍선이 도넛 외곽에 위치하도록 offset 계산
    private var bubbleOffset: CGSize {
        guard let selectedID else { return .zero }

        let validSegments = item.items.filter { $0.value > 0 }
        let total = validSegments.map(\.value).reduce(0, +)
        guard total > 0 else { return .zero }

        let segmentCount = Double(validSegments.count)
        let gapDegrees: Double = 0
        let safeGap = segmentCount > 1
            ? max(0, min(gapDegrees, (360.0 / segmentCount) * 0.6))
            : 0
        let available = 360.0 - safeGap * segmentCount

        var current = 0.0
        var centerAngleDeg: Double = 0
        for seg in validSegments {
            let portion = seg.value / total
            let span = available * portion
            if seg.id == selectedID {
                centerAngleDeg = current + span / 2
                break
            }
            current += span + safeGap
        }

        // DonutChartView 기본 rotationDegrees: -90 (12시 방향 시작)
        let actualRad = (centerAngleDeg - 90) * .pi / 180
        let radius: CGFloat = 116
        let x = CGFloat(Foundation.cos(actualRad)) * radius
        let y = CGFloat(Foundation.sin(actualRad)) * radius
        return CGSize(width: x, height: y)
    }

    var body: some View {
        ZStack {
            DonutChartView(
                segments: item.items,
                selectedID: $selectedID,
                thickness: 54,
                gapDegrees: 0,
                cornerRadius: 7,
                selectedOuterExtension: 5,
                selectedInnerExtension: 3,
                selectedAngularInset: 1.5
            ) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 2)
                        .frame(width: 135, height: 135)

                    Text(item.categoryName)
                        .font(.codive_title1)
                        .foregroundStyle(Color.Codive.grayscale1)
                }
            }
            .frame(width: 240, height: 240)

            if let seg = selectedSegment {
                BubbleLabelView(
                    title: seg.payload ?? "",
                    percent: selectedPercent
                )
                .offset(bubbleOffset)
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedID)
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            // 가장 점유율 큰 segment 자동 강조 + 바텀시트 갱신
            let maxSeg = item.items.max(by: { $0.value < $1.value })
            selectedID = maxSeg?.id
            if let seg = maxSeg {
                onSelectSegment(seg.payload ?? item.categoryName, [])
            }
        }
        .onChange(of: selectedID) { _ in
            if let seg = selectedSegment {
                onSelectSegment(seg.payload ?? item.categoryName, [])
            }
        }
    }
}

// MARK: - BubbleLabelView

private struct BubbleLabelView: View {
    let title: String
    let percent: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale1)

            Text("\(percent)%")
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - Preview

#if DEBUG
private final class PreviewCategoryRepo: StatisticsRepository {
    func checkStatisticsCondition() async throws -> Bool { true }
    func getFavoriteItems() async throws -> [FavoriteItemPayload] { [] }

    func getFavoriteCategoryItems(categoryId: Int64) async throws -> [FavoriteCategoryItemPayload] {
        switch categoryId {
        case 1:
            return [
                FavoriteCategoryItemPayload(categoryId: 11, categoryName: "맨투맨", occupancyRate: 30, clothCount: 5),
                FavoriteCategoryItemPayload(categoryId: 12, categoryName: "후드티", occupancyRate: 45, clothCount: 8),
                FavoriteCategoryItemPayload(categoryId: 13, categoryName: "셔츠", occupancyRate: 15, clothCount: 3),
                FavoriteCategoryItemPayload(categoryId: 14, categoryName: "기타", occupancyRate: 10, clothCount: 2)
            ]
        case 2:
            return [
                FavoriteCategoryItemPayload(categoryId: 21, categoryName: "청바지", occupancyRate: 50, clothCount: 5),
                FavoriteCategoryItemPayload(categoryId: 22, categoryName: "면바지", occupancyRate: 30, clothCount: 3),
                FavoriteCategoryItemPayload(categoryId: 23, categoryName: "반바지", occupancyRate: 20, clothCount: 2)
            ]
        case 3:
            return [
                FavoriteCategoryItemPayload(categoryId: 31, categoryName: "코트", occupancyRate: 40, clothCount: 4),
                FavoriteCategoryItemPayload(categoryId: 32, categoryName: "패딩", occupancyRate: 35, clothCount: 3),
                FavoriteCategoryItemPayload(categoryId: 33, categoryName: "자켓", occupancyRate: 25, clothCount: 2)
            ]
        default:
            return []
        }
    }

    func getClosetUtilization(season: String) async throws -> ClosetUtilizationPayload {
        ClosetUtilizationPayload(utilizedCount: 0, unutilizedCount: 0, utilizedClothes: [], unutilizedClothes: [])
    }
}

@MainActor
private func makePreviewVM() -> FavoriteByCategoryViewModel {
    let repo = PreviewCategoryRepo()
    let vm = FavoriteByCategoryViewModel(
        navigationRouter: NavigationRouter(),
        fetchFavoriteCategoryItemsUseCase: FetchFavoriteCategoryItemsUseCase(repository: repo),
        fetchClothListByCategoryUseCase: FetchClothListByCategoryUseCase(repository: PreviewEmptyClothRepo()),
        parentCategoryId: 1
    )
    // .task가 호출되기 전 첫 프레임부터 데이터 있도록 미리 채움
    vm.categories = [
        CategoryFavoriteItem(
            parentCategoryId: 1,
            categoryName: "상의",
            items: [
                DonutSegment(value: 30, color: .Codive.point1, payload: "맨투맨"),
                DonutSegment(value: 45, color: .Codive.point2, payload: "후드티"),
                DonutSegment(value: 15, color: .Codive.point3, payload: "셔츠"),
                DonutSegment(value: 10, color: .Codive.grayscale5, payload: "기타")
            ]
        )
    ]
    // segment별 mock 옷 매핑 — 도넛 탭 시 바텀시트가 갱신됨
    vm.clothesBySegment = [
        "맨투맨": (0..<6).map { _ in
            ClothItem(imageUrl: "", brand: "유니클로", name: "Crew neck sweat")
        },
        "후드티": (0..<11).map { _ in
            ClothItem(imageUrl: "", brand: "나이키", name: "Cable knit cardigan navy color")
        },
        "셔츠": (0..<3).map { _ in
            ClothItem(imageUrl: "", brand: "무신사", name: "Oxford shirt white")
        },
        "기타": (0..<2).map { _ in
            ClothItem(imageUrl: "", brand: "아디다스", name: "Polo collar tee")
        }
    ]
    // 첫 진입 시 후드티 자동 선택
    vm.selectSegment(name: "후드티")
    return vm
}

#Preview {
    FavoriteByCategoryView(viewModel: makePreviewVM())
}
#endif
