//
//  FavoriteByCategoryView.swift
//  Codive
//
//  Created by 한태빈 on 12/19/25.
//
import SwiftUI

struct FavoriteByCategoryView: View {
    let items: [CategoryFavoriteItem]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CustomNavigationBar(title: "카테고리 통계") {
                dismiss()
            }
            .background(Color.Codive.grayscale7)

            Text("그래프를 눌러 구체적인 히스토리를 살펴보세요")
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale3)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 12)

            ScrollView {
                VStack(spacing: 28) {
                    ForEach(items) { item in
                        CategoryDonutSection(item: item)
                    }
                }
                .padding(.top, 22)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

private struct CategoryDonutSection: View {
    let item: CategoryFavoriteItem
    @State private var selectedID: DonutSegment.ID?
    @State private var isBottomSheetPresented = false
    @State private var bottomSheetTitle = ""
    @State private var bottomSheetItems: [DataBottomSheetClothItem] = []
    @State private var isFirstLoad = true

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

    var body: some View {
        ZStack {
            DonutChartView(
                segments: item.items,
                selectedID: $selectedID,
                thickness: 50,
                gapDegrees: 5
            ) {
                Text(item.categoryName)
                    .font(.codive_title1)
                    .foregroundStyle(Color.Codive.grayscale1)
            }
            .frame(width: 196, height: 196)
            .onChange(of: selectedID) { newValue in
                if isFirstLoad {
                    isFirstLoad = false
                    return
                }
                if let seg = item.items.first(where: { $0.id == newValue }) {
                    bottomSheetTitle = seg.payload ?? item.categoryName
                    // Mock Data: 값에 따라 개수 임의 생성 (3~10개)
                    let count = Int(seg.value) > 0 ? Int(seg.value) + 2 : 5
                    bottomSheetItems = makeMockItems(count: count)
                    isBottomSheetPresented = true
                }
            }

            if let seg = selectedSegment {
                BubbleLabelView(
                    title: seg.payload ?? "",
                    percent: selectedPercent
                )
                .offset(x: 68, y: -62)
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .onAppear {
            selectedID = item.items.first?.id
            // onAppear 시점에는 아직 사용자가 탭한 게 아니므로 isFirstLoad는 true 유지
            // 하지만 onChange가 호출될 수 있으므로 약간의 지연 후 false 처리하거나
            // 여기서는 selectedID 할당이 onChange를 즉시 호출하므로 위 onChange 가드문으로 방어
        }
        .dataBottomSheet(
            isPresented: $isBottomSheetPresented,
            dataBottomSheetTitle: bottomSheetTitle,
            totalCount: bottomSheetItems.count,
            items: bottomSheetItems
        )
    }

    private func makeMockItems(count: Int) -> [DataBottomSheetClothItem] {
        (0..<count).map { i in
            DataBottomSheetClothItem(
                imageName: "samplecloth",
                brand: "Nike",
                title: "Mock Item \(i + 1)"
            )
        }
    }
}

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
            SpeechBubbleShape()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
        )
    }
}
#Preview {
    FavoriteByCategoryView(items: [
        CategoryFavoriteItem(
            categoryName: "상의",
            items: [
                DonutSegment(value: 5, color: Color.Codive.point1, payload: "맨투맨"),
                DonutSegment(value: 3, color: Color.Codive.point2, payload: "후드티"),
                DonutSegment(value: 2, color: Color.Codive.point3, payload: "셔츠")
            ]
        ),
    ])
}
