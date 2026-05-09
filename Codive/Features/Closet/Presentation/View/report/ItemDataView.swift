//
//  ItemDataView.swift
//  Codive
//
//  Created by 한태빈 on 12/19/25.
//

import SwiftUI

struct ItemDataView: View {

    @StateObject private var viewModel: ItemDataViewModel
    @State private var isExpanded: Bool = false

    private let collapsedHeight: CGFloat = 420

    init(viewModel: ItemDataViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // 메인 콘텐츠 (차트 상단)
                VStack(spacing: 0) {
                    CustomNavigationBar(title: "수량 통계") {
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
                    } else if !viewModel.stats.isEmpty {
                        chartView
                            .padding(.top, 32)
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
            .navigationBarHidden(true)
            .task {
                await viewModel.loadData()
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }

    // MARK: - Chart

    private var chartView: some View {
        let chartHeight: CGFloat = 200
        let barCornerRadius: CGFloat = 12
        let barSpacing: CGFloat = 18
        let minBarHeight: CGFloat = 12
        let maxCount = max(viewModel.stats.map(\.usageCount).max() ?? 1, 1)
        // 점선 기준값: 선택된 막대 높이 (없으면 최대값)
        let dashValue: Int = {
            if let idx = viewModel.selectedIndex,
               viewModel.stats.indices.contains(idx) {
                return viewModel.stats[idx].usageCount
            }
            return viewModel.stats.map(\.usageCount).max() ?? 1
        }()

        return VStack(spacing: 0) {
            GeometryReader { geo in
                let width = geo.size.width
                let count = max(viewModel.stats.count, 1)
                let barWidth = (width - barSpacing * CGFloat(count - 1)) / CGFloat(count)

                ZStack(alignment: .bottomLeading) {
                    // 막대들
                    HStack(alignment: .bottom, spacing: barSpacing) {
                        ForEach(Array(viewModel.stats.enumerated()), id: \.offset) { idx, item in
                            let barHeight = max(
                                minBarHeight,
                                CGFloat(item.usageCount) / CGFloat(maxCount) * chartHeight
                            )
                            let isSelected = viewModel.selectedIndex == idx

                            RoundedTopRectangle(cornerRadius: barCornerRadius)
                                .fill(isSelected ? Color.Codive.point1 : Color.Codive.grayscale6)
                                .frame(width: barWidth, height: barHeight)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        viewModel.selectBar(at: idx)
                                    }
                                }
                        }
                    }

                    // 점선: 선택된 막대 높이 기준 — 막대 위에 그려짐
                    let dashY = chartHeight - (CGFloat(dashValue) / CGFloat(maxCount) * chartHeight)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: dashY))
                        path.addLine(to: CGPoint(x: width, y: dashY))
                    }
                    .stroke(
                        Color.Codive.point1,
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: dashValue)
                    .zIndex(5)

                    // 강조 막대 위 카운트 박스
                    if let selectedIndex = viewModel.selectedIndex,
                       viewModel.stats.indices.contains(selectedIndex) {
                        let selectedValue = viewModel.stats[selectedIndex].usageCount
                        let selectedHeight = CGFloat(selectedValue) / CGFloat(maxCount) * chartHeight
                        let yPosition = chartHeight - selectedHeight
                        let centerX = (barWidth / 2) + (barWidth + barSpacing) * CGFloat(selectedIndex)

                        CountBadge(text: "\(selectedValue)벌")
                            .position(x: centerX, y: yPosition - 18)
                            .zIndex(10)
                    }
                }
            }
            .frame(height: chartHeight)
            .padding(.horizontal, 24)
            .padding(.top, 32)

            // 카테고리 이름
            HStack(alignment: .top, spacing: 18) {
                ForEach(Array(viewModel.stats.enumerated()), id: \.offset) { _, item in
                    Text(item.itemName)
                        .font(.codive_body3_medium)
                        .foregroundStyle(Color.Codive.grayscale3)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
    }
}

// MARK: - CountBadge

private struct CountBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.codive_body3_medium)
            .foregroundStyle(Color.Codive.grayscale1)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
    }
}

// MARK: - RoundedTopRectangle

struct RoundedTopRectangle: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(cornerRadius, rect.width / 2, rect.height / 2)

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview

private final class PreviewItemRepo: StatisticsRepository {
    func checkStatisticsCondition() async throws -> Bool { true }

    func getFavoriteItems() async throws -> [FavoriteItemPayload] {
        [
            FavoriteItemPayload(categoryId: 1, categoryName: "맨투맨", clothCount: 10),
            FavoriteItemPayload(categoryId: 2, categoryName: "원피스", clothCount: 8),
            FavoriteItemPayload(categoryId: 3, categoryName: "니트", clothCount: 5),
            FavoriteItemPayload(categoryId: 4, categoryName: "후드티", clothCount: 3),
            FavoriteItemPayload(categoryId: 5, categoryName: "레깅스", clothCount: 2)
        ]
    }

    func getFavoriteCategoryItems(categoryId: Int64) async throws -> [FavoriteCategoryItemPayload] { [] }
    func getClosetUtilization(season: String) async throws -> ClosetUtilizationPayload {
        ClosetUtilizationPayload(utilizedCount: 0, unutilizedCount: 0, utilizedClothes: [], unutilizedClothes: [])
    }
}

@MainActor
private func makePreviewVM(selectedIndex: Int = 1) -> ItemDataViewModel {
    let repo = PreviewItemRepo()
    let vm = ItemDataViewModel(
        navigationRouter: NavigationRouter(),
        fetchFavoriteItemsUseCase: FetchFavoriteItemsUseCase(repository: repo),
        clothRepository: PreviewEmptyClothRepo()
    )
    vm.stats = [
        ItemUsageStat(itemName: "맨투맨", usageCount: 10),
        ItemUsageStat(itemName: "원피스", usageCount: 8),
        ItemUsageStat(itemName: "니트", usageCount: 5),
        ItemUsageStat(itemName: "후드티", usageCount: 3),
        ItemUsageStat(itemName: "레깅스", usageCount: 2)
    ]
    vm.clothesByItem = [
        "맨투맨": (0..<10).map { _ in
            ClothItem(imageUrl: "", brand: "유니클로", name: "Crew neck sweat")
        },
        "원피스": (0..<11).map { _ in
            ClothItem(imageUrl: "", brand: "나이키", name: "Cable knit cardigan navy color")
        },
        "니트": (0..<11).map { _ in
            ClothItem(imageUrl: "", brand: "무신사", name: "Wool blend knit beige")
        },
        "후드티": (0..<3).map { _ in
            ClothItem(imageUrl: "", brand: "아디다스", name: "Pullover hoodie black")
        },
        "레깅스": (0..<2).map { _ in
            ClothItem(imageUrl: "", brand: "젝시믹스", name: "Tight leggings")
        }
    ]
    vm.selectBar(at: selectedIndex)
    return vm
}

#Preview("디자인 매칭 - 원피스 강조") {
    ItemDataView(viewModel: makePreviewVM(selectedIndex: 1))
}

#Preview("니트 강조") {
    ItemDataView(viewModel: makePreviewVM(selectedIndex: 2))
}
