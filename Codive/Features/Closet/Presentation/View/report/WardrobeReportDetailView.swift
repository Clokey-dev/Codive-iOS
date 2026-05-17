//
//  WardrobeReportDetailView.swift
//  Codive
//
//  Created by 황상환 on 2/26/26.
//

import SwiftUI

struct WardrobeReportDetailView: View {

    // MARK: - Properties
    @StateObject private var viewModel: WardrobeReportDetailViewModel
    @State private var showingTooltip: String?

    // MARK: - Initializer
    init(viewModel: WardrobeReportDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    loadingView
                } else if !viewModel.canAggregate {
                    insufficientDataView
                } else {
                    reportContentView
                }
            }
            .background(Color.white)
            .contentShape(Rectangle())
            .onTapGesture {
                if showingTooltip != nil {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingTooltip = nil
                    }
                }
            }
        }
        .overlayPreferenceValue(TooltipAnchorKey.self) { tooltipAnchor in
            GeometryReader { proxy in
                if let tooltipAnchor {
                    let rect = proxy[tooltipAnchor.anchor]
                    TooltipBubbleView(text: tooltipAnchor.text)
                        .frame(maxWidth: proxy.size.width - 40, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .offset(x: 20, y: rect.maxY + 8)
                        .transition(.opacity)
                }
            }
            .allowsHitTesting(false)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadReport()
        }
        .alert(
            "네트워크 오류",
            isPresented: $viewModel.isShowingNetworkErrorAlert
        ) {
            Button("재시도") {
                Task { await viewModel.loadReport() }
            }
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.networkErrorMessage ?? "네트워크 오류가 발생했습니다.")
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            CustomNavigationBar(
                title: "\(viewModel.currentMonth)월 옷장 리포트"
            ) {
                viewModel.navigateBack()
            }
            Spacer()
            ProgressView()
            Spacer()
        }
    }

    // MARK: - Insufficient Data View
    private var insufficientDataView: some View {
        VStack(spacing: 8) {
            CustomNavigationBar(
                title: "\(viewModel.currentMonth)월 옷장 리포트"
            ) {
                viewModel.navigateBack()
            }

            Spacer()

            Text("리포트를 완성하기엔\n히스토리가 적어요")
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)
                .multilineTextAlignment(.center)

            Text("피드와 코디 기록이 쌓이면\n리포트가 완성돼요. 하나 기록해볼까요?")
                .font(.codive_body2_regular)
                .foregroundStyle(Color.Codive.grayscale3)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            CustomButton(
                text: "피드 작성하러 가기",
                widthType: .dynamic
            ) {
                viewModel.navigateToRecordAdd()
            }
            .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color.white)
    }

    // MARK: - Report Content View
    private var reportContentView: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "\(viewModel.currentMonth)월 옷장 리포트"
            ) {
                viewModel.navigateBack()
            }
            .background(Color.white)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.dateRangeString)
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale3)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                    FavoriteByCategorySection(
                        categories: viewModel.favoriteCategories,
                        showingTooltip: $showingTooltip
                    ) { categoryId in
                        viewModel.navigateToFavoriteCategory(parentCategoryId: categoryId)
                    }
                    .padding(.top, 40)

                    ItemStatsSection(
                        stats: viewModel.favoriteItems,
                        showingTooltip: $showingTooltip
                    ) {
                        viewModel.navigateToItemStats()
                    }
                    .padding(.top, 40)

                    UsageCheckSection(
                        usage: viewModel.wardrobeUsage,
                        topItemName: viewModel.topUtilizedItemName,
                        showingTooltip: $showingTooltip
                    ) {
                        viewModel.navigateToUsageCheck()
                    }
                    .padding(.top, 40)

                    Spacer(minLength: 24)
                }
            }
        }
    }

}

// MARK: - Preview

private final class PreviewStatisticsRepository: StatisticsRepository {
    let canAggregate: Bool
    init(canAggregate: Bool = true) {
        self.canAggregate = canAggregate
    }

    func checkStatisticsCondition() async throws -> Bool { canAggregate }

    func getFavoriteItems() async throws -> [FavoriteItemPayload] {
        [
            FavoriteItemPayload(categoryId: 1, categoryName: "맨투맨", clothCount: 8),
            FavoriteItemPayload(categoryId: 2, categoryName: "원피스", clothCount: 6),
            FavoriteItemPayload(categoryId: 3, categoryName: "니트", clothCount: 4),
            FavoriteItemPayload(categoryId: 4, categoryName: "후드티", clothCount: 3),
            FavoriteItemPayload(categoryId: 5, categoryName: "레깅스", clothCount: 2)
        ]
    }

    func getFavoriteCategoryItems(categoryId: Int64) async throws -> [FavoriteCategoryItemPayload] {
        switch categoryId {
        case 1:
            return [
                FavoriteCategoryItemPayload(categoryId: 11, categoryName: "맨투맨", occupancyRate: 45, clothCount: 8),
                FavoriteCategoryItemPayload(categoryId: 12, categoryName: "후드티", occupancyRate: 30, clothCount: 5),
                FavoriteCategoryItemPayload(categoryId: 13, categoryName: "셔츠", occupancyRate: 15, clothCount: 3),
                FavoriteCategoryItemPayload(categoryId: 14, categoryName: "기타", occupancyRate: 10, clothCount: 2)
            ]
        case 2:
            return [
                FavoriteCategoryItemPayload(categoryId: 21, categoryName: "청바지", occupancyRate: 60, clothCount: 6),
                FavoriteCategoryItemPayload(categoryId: 22, categoryName: "면바지", occupancyRate: 25, clothCount: 3),
                FavoriteCategoryItemPayload(categoryId: 23, categoryName: "반바지", occupancyRate: 15, clothCount: 1)
            ]
        default:
            return []
        }
    }

    func getClosetUtilization(season: String) async throws -> ClosetUtilizationPayload {
        ClosetUtilizationPayload(
            utilizedCount: 8,
            unutilizedCount: 12,
            utilizedClothes: [
                ClosetUtilizationClothPayload(imageUrl: "", name: "나시", brand: "Brand"),
                ClosetUtilizationClothPayload(imageUrl: "", name: "맨투맨", brand: "Brand")
            ],
            unutilizedClothes: [
                ClosetUtilizationClothPayload(imageUrl: "", name: "셔츠", brand: "Brand")
            ]
        )
    }
}

@MainActor
private func makePreviewViewModel(canAggregate: Bool = true) -> WardrobeReportDetailViewModel {
    let repo = PreviewStatisticsRepository(canAggregate: canAggregate)
    return WardrobeReportDetailViewModel(
        navigationRouter: NavigationRouter(),
        checkStatisticsConditionUseCase: CheckStatisticsConditionUseCase(repository: repo),
        fetchFavoriteItemsUseCase: FetchFavoriteItemsUseCase(repository: repo),
        fetchFavoriteCategoryItemsUseCase: FetchFavoriteCategoryItemsUseCase(repository: repo),
        fetchClosetUtilizationUseCase: FetchClosetUtilizationUseCase(repository: repo)
    )
}

#Preview("리포트 - 데이터 있음") {
    WardrobeReportDetailView(viewModel: makePreviewViewModel())
}

#Preview("리포트 - 데이터 부족") {
    WardrobeReportDetailView(viewModel: makePreviewViewModel(canAggregate: false))
}
