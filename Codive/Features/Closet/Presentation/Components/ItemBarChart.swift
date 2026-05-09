//
//  ItemBarChart.swift
//  Codive
//
//  Created by 황상환 on 5/5/26.
//

import SwiftUI

struct ItemBarChart: View {
    let stats: [ItemUsageStat]
    var maxBarHeight: CGFloat = 140
    var unitSuffix: String = "벌"

    private let barCornerRadius: CGFloat = 8
    private let minBarHeight: CGFloat = 12

    private var maxCount: Int {
        max(stats.map(\.usageCount).max() ?? 1, 1)
    }

    // 수량 기준으로 내림차순 정렬 (가장 많은 것이 가장 진한 색)
    private var sortedStats: [ItemUsageStat] {
        stats.sorted { $0.usageCount > $1.usageCount }
    }

    private let barColors: [Color] = [
        Color.Codive.point1,
        Color.Codive.point2,
        Color.Codive.point3,
        Color.Codive.main5,
        Color.Codive.grayscale6
    ]

    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            ForEach(Array(sortedStats.enumerated()), id: \.offset) { idx, item in
                let isHighlighted = idx == 0
                let height = max(
                    minBarHeight,
                    CGFloat(item.usageCount) / CGFloat(maxCount) * maxBarHeight
                )

                VStack(spacing: 8) {
                    ZStack(alignment: .top) {
                        TopRoundedRectangle(cornerRadius: barCornerRadius)
                            .fill(barColors[min(idx, barColors.count - 1)])
                            .frame(maxWidth: .infinity)
                            .frame(height: height)

                        if isHighlighted {
                            highlightLabel(count: item.usageCount)
                                .offset(y: 6)
                        }
                    }
                    .frame(height: maxBarHeight, alignment: .bottom)

                    Text(item.itemName)
                        .font(.codive_body3_medium)
                        .foregroundStyle(Color.Codive.grayscale3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity)
            }
        }
        // 카드 내부 padding 16 + 여기 24 = 카드 가장자리 기준 40 좌우 여백
        .padding(.horizontal, 24)
    }

    private func highlightLabel(count: Int) -> some View {
        Text("\(count)\(unitSuffix)")
            .font(.codive_body3_medium)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.Codive.point1)
            )
    }
}

// MARK: - TopRoundedRectangle
// 위쪽 두 모서리만 둥근 사각형. 막대 차트 막대 모양 등에 사용.

private struct TopRoundedRectangle: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = max(0, min(cornerRadius, min(rect.width, rect.height) / 2))

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + r, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + r),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview("디자인 매칭") {
    ItemBarChart(
        stats: [
            ItemUsageStat(itemName: "맨투맨", usageCount: 8),
            ItemUsageStat(itemName: "원피스", usageCount: 6),
            ItemUsageStat(itemName: "니트", usageCount: 4),
            ItemUsageStat(itemName: "후드티", usageCount: 3),
            ItemUsageStat(itemName: "레깅스", usageCount: 2)
        ]
    )
    .padding()
    .background(Color.white)
}

#Preview("값 차이 큰 케이스") {
    ItemBarChart(
        stats: [
            ItemUsageStat(itemName: "티셔츠", usageCount: 20),
            ItemUsageStat(itemName: "셔츠", usageCount: 5),
            ItemUsageStat(itemName: "니트", usageCount: 3),
            ItemUsageStat(itemName: "후드티", usageCount: 2),
            ItemUsageStat(itemName: "맨투맨", usageCount: 1)
        ]
    )
    .padding()
    .background(Color.white)
}
