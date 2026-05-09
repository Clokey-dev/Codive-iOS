//
//  UsageDonutChart.swift
//  Codive
//
//  Created by 황상환 on 5/5/26.
//

import SwiftUI

struct UsageDonutChart: View {
    let stats: WardrobeUsageStat
    @State private var segments: [DonutSegment] = []
    @State private var selectedID: DonutSegment.ID?

    var body: some View {
        DonutChartView(
            segments: segments,
            selectedID: $selectedID,
            thickness: 26,
            gapDegrees: 0,
            cornerRadius: 0,
            selectedOuterExtension: 0,
            selectedInnerExtension: 0,
            selectedAngularInset: 0
        ) {
            Text("\(stats.usagePercent)%")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.Codive.point1)
        }
        .onAppear(perform: rebuild)
        .onChange(of: stats) { _ in rebuild() }
    }

    private func rebuild() {
        var newSegments: [DonutSegment] = []
        if stats.wornCount > 0 {
            newSegments.append(
                DonutSegment(
                    value: Double(stats.wornCount),
                    color: Color.Codive.point1,
                    payload: "입음"
                )
            )
        }
        let notWorn = max(0, stats.totalCount - stats.wornCount)
        if notWorn > 0 {
            newSegments.append(
                DonutSegment(
                    value: Double(notWorn),
                    color: Color.Codive.point4,
                    payload: "미착용"
                )
            )
        }
        segments = newSegments
        selectedID = nil
    }
}

// MARK: - Preview

#Preview("디자인 매칭 - 40%") {
    UsageDonutChart(
        stats: WardrobeUsageStat(totalCount: 20, wornCount: 8)
    )
    .frame(width: 130, height: 130)
    .padding()
    .background(Color.white)
}

#Preview("70% 활용") {
    UsageDonutChart(
        stats: WardrobeUsageStat(totalCount: 30, wornCount: 21)
    )
    .frame(width: 130, height: 130)
    .padding()
    .background(Color.white)
}

#Preview("100% 활용") {
    UsageDonutChart(
        stats: WardrobeUsageStat(totalCount: 15, wornCount: 15)
    )
    .frame(width: 130, height: 130)
    .padding()
    .background(Color.white)
}

#Preview("0% 활용") {
    UsageDonutChart(
        stats: WardrobeUsageStat(totalCount: 15, wornCount: 0)
    )
    .frame(width: 130, height: 130)
    .padding()
    .background(Color.white)
}
