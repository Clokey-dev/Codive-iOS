//
//  WearingDataView.swift
//  Codive
//
//  Created by 한태빈 on 12/19/25.
//

import SwiftUI

struct WearingDataView: View {

    @StateObject private var viewModel: WearingDataViewModel
    @State private var isExpanded: Bool = false

    private let collapsedHeight: CGFloat = 420

    init(viewModel: WearingDataViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // 메인 콘텐츠 (도넛 상단)
                VStack(spacing: 0) {
                    CustomNavigationBar(title: "활용도 체크") {
                        viewModel.navigateBack()
                    }
                    .background(Color.white)

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        Text(viewModel.subtitleText)
                            .font(.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale3)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.top, 12)

                        usageChart
                            .padding(.top, 28)

                        Spacer(minLength: 0)
                        // 바텀시트 영역 확보
                        Color.clear.frame(height: collapsedHeight - 60)
                    }
                }

                // 바텀시트 (페이지 하단에 고정)
                DataBottomSheet(
                    title: viewModel.selectedBottomSheetTitle,
                    totalCount: viewModel.stats.totalCount,
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

    // MARK: - Usage Chart

    private var usageChart: some View {
        let safeTotal = max(0, viewModel.stats.totalCount)
        let safeWorn = max(0, min(viewModel.stats.wornCount, safeTotal))
        let notWorn = max(0, safeTotal - safeWorn)
        let isWornSelected = viewModel.selectedPayload == "입음"

        let segments: [DonutSegment] = [
            DonutSegment(
                value: Double(safeWorn),
                color: isWornSelected ? Color.Codive.point1 : Color.Codive.point4,
                payload: "입음"
            ),
            DonutSegment(
                value: Double(notWorn),
                color: isWornSelected ? Color.Codive.point4 : Color.Codive.point1,
                payload: "미착용"
            )
        ]

        // selectedPayload로부터 ID를 매번 동기화
        let selectedIDBinding = Binding<DonutSegment.ID?>(
            get: { segments.first(where: { $0.payload == viewModel.selectedPayload })?.id },
            set: { newID in
                if let payload = segments.first(where: { $0.id == newID })?.payload {
                    viewModel.selectSegment(payload: payload)
                }
            }
        )

        return DonutChartView(
            segments: segments,
            selectedID: selectedIDBinding,
            thickness: 50,
            gapDegrees: 0,
            cornerRadius: 8,
            selectedOuterExtension: 6,
            selectedInnerExtension: 4,
            selectedAngularInset: 1.5
        ) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 2)
                    .frame(width: 130, height: 130)

                Text("\(viewModel.centerPercent)%")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.Codive.point1)
            }
        }
        .frame(width: 240, height: 240)
    }
}

// MARK: - Preview

private final class PreviewWearingRepo: StatisticsRepository {
    let utilized: Int
    let unutilized: Int

    init(utilized: Int, unutilized: Int) {
        self.utilized = utilized
        self.unutilized = unutilized
    }

    func checkStatisticsCondition() async throws -> Bool { true }
    func getFavoriteItems() async throws -> [FavoriteItemPayload] { [] }
    func getFavoriteCategoryItems(categoryId: Int64) async throws -> [FavoriteCategoryItemPayload] { [] }

    func getClosetUtilization(season: String) async throws -> ClosetUtilizationPayload {
        ClosetUtilizationPayload(
            utilizedCount: utilized,
            unutilizedCount: unutilized,
            utilizedClothes: (0..<utilized).map { _ in
                ClosetUtilizationClothPayload(imageUrl: "", name: "Cable knit cardigan navy color", brand: "나이키")
            },
            unutilizedClothes: (0..<unutilized).map { _ in
                ClosetUtilizationClothPayload(imageUrl: "", name: "Cable knit cardigan navy color", brand: "나이키")
            }
        )
    }
}

@MainActor
private func makePreviewVM(initialPayload: String = "입음") -> WearingDataViewModel {
    let repo = PreviewWearingRepo(utilized: 8, unutilized: 12)
    let vm = WearingDataViewModel(
        navigationRouter: NavigationRouter(),
        fetchClosetUtilizationUseCase: FetchClosetUtilizationUseCase(repository: repo)
    )
    // 첫 프레임부터 데이터 있도록 미리 채움
    vm.stats = WardrobeUsageStat(totalCount: 20, wornCount: 8)
    vm.utilizedClothes = (0..<8).map { _ in
        ClothItem(imageUrl: "", brand: "나이키", name: "Cable knit cardigan navy color")
    }
    vm.unutilizedClothes = (0..<12).map { _ in
        ClothItem(imageUrl: "", brand: "나이키", name: "Cable knit cardigan navy color")
    }
    vm.selectSegment(payload: initialPayload)
    return vm
}

#Preview("입음 강조 (40%)") {
    WearingDataView(viewModel: makePreviewVM(initialPayload: "입음"))
}

#Preview("미착용 강조 (60%)") {
    WearingDataView(viewModel: makePreviewVM(initialPayload: "미착용"))
}
