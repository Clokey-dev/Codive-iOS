//
//  ItemDataView.swift
//  Codive
//
//  Created by 한태빈 on 12/19/25.
//

import SwiftUI

struct ItemDataView: View {
    let stats: [ItemUsageStat]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int? = nil
    
    // Bottom Sheet
    @State private var isBottomSheetPresented = false
    @State private var bottomSheetTitle = ""
    @State private var bottomSheetItems: [DataBottomSheetClothItem] = []

    private let chartHeight: CGFloat = 200

    private let barCornerRadius: CGFloat = 12
    private let barSpacing: CGFloat = 14
    private let minBarHeight: CGFloat = 8
    private let badgeVerticalOffset: CGFloat = 18

    private var maxCount: Int {
        max(stats.map(\.usageCount).max() ?? 1, 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "수량 통계") {
                dismiss()
            }
            .background(Color.Codive.grayscale7)

            Text("그래프를 눌러 구체적인 히스토리를 살펴보세요")
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale3)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 12)

            ScrollView {
                VStack(spacing: 20) {
                    chartCard
                }
                .padding(.top, 22)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .onAppear {
            if selectedIndex == nil, !stats.isEmpty {
                selectedIndex = 0
            }
        }
        .dataBottomSheet(
            isPresented: $isBottomSheetPresented,
            dataBottomSheetTitle: bottomSheetTitle,
            totalCount: bottomSheetItems.count,
            items: bottomSheetItems
        )
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeometryReader { geo in
                let width = geo.size.width
                let count = max(stats.count, 1)
                let barWidth = (width - barSpacing * CGFloat(count - 1)) / CGFloat(count)

                ZStack(alignment: .bottomLeading) {

                    HStack(alignment: .bottom, spacing: barSpacing) {
                        ForEach(Array(stats.enumerated()), id: \.offset) { idx, item in
                            let h = max(minBarHeight, CGFloat(item.usageCount) / CGFloat(maxCount) * chartHeight)

                            RoundedTopRectangle(cornerRadius: barCornerRadius)
                                .fill(barFillColor(for: idx))
                                .frame(width: barWidth, height: h)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        selectedIndex = idx
                                    }
                                    
                                    // 바텀시트 띄우기
                                    bottomSheetTitle = item.itemName
                                    bottomSheetItems = makeMockItems(count: item.usageCount)
                                    isBottomSheetPresented = true
                                }
                        }
                    }

                    if let selectedIndex, stats.indices.contains(selectedIndex) {
                        let selectedValue = stats[selectedIndex].usageCount
                        let selectedHeight = CGFloat(selectedValue) / CGFloat(maxCount) * chartHeight
                        let y = chartHeight - selectedHeight
                        let centerX = (barWidth / 2) + (barWidth + barSpacing) * CGFloat(selectedIndex)

                        CountBadge(text: "\(selectedValue)벌")
                            .position(x: centerX, y: y - badgeVerticalOffset)
                            .zIndex(10)
                    }
                }
            }
            .frame(height: chartHeight)
            .padding(.horizontal, 20)
            .padding(.top, 47)

            HStack(alignment: .top, spacing: barSpacing) {
                ForEach(Array(stats.enumerated()), id: \.offset) { _, item in
                    Text(item.itemName)
                        .font(.caption)
                        .foregroundStyle(Color.Codive.grayscale3)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
    }

    private func barFillColor(for index: Int) -> Color {
        if selectedIndex == index {
            return Color.Codive.point1
        }
        return Color.Codive.main5
    }

    private func makeMockItems(count: Int) -> [DataBottomSheetClothItem] {
        // count만큼 아이템 생성 (최대 20개로 제한 등은 필요 시 추가)
        let safeCount = max(0, count)
        return (0..<safeCount).map { i in
            DataBottomSheetClothItem(
                imageName: "samplecloth",
                brand: "MockBrand",
                title: "Item Data Mock \(i + 1)"
            )
        }
    }
}

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

private struct RoundedTopRectangle: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()

        let r = min(cornerRadius, rect.width / 2, rect.height / 2)

        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        p.addArc(
            center: CGPoint(x: rect.minX + r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addArc(
            center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()

        return p
    }
}
#Preview {
    ItemDataView(stats: [
        ItemUsageStat(itemName: "맨투맨", usageCount: 20),
        ItemUsageStat(itemName: "원피스", usageCount: 15),
        ItemUsageStat(itemName: "니트", usageCount: 12),
        ItemUsageStat(itemName: "후드티", usageCount: 8),
        ItemUsageStat(itemName: "레깅스", usageCount: 5)
    ])
}
