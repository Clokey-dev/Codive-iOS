//
//  ItemStatsSection.swift
//  Codive
//
//  Created by 황상환 on 5/5/26.
//

import SwiftUI

struct ItemStatsSection: View {

    let stats: [ItemUsageStat]
    @Binding var showingTooltip: String?
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ReportSectionHeader(
                title: "옷장 아이템 통계",
                tooltip: "전체 아이템 중 많이 보유한 아이템\nTOP 5를 확인할 수 있는 그래프입니다",
                showingTooltip: $showingTooltip
            )

            ReportCardContainer {
                ItemBarChart(stats: stats, maxBarHeight: 140)
            }
            .onTapGesture { onTap() }
        }
    }
}

// MARK: - Preview

#Preview("디자인 매칭") {
    ScrollView {
        ItemStatsSection(
            stats: [
                ItemUsageStat(itemName: "맨투맨", usageCount: 8),
                ItemUsageStat(itemName: "원피스", usageCount: 6),
                ItemUsageStat(itemName: "니트", usageCount: 4),
                ItemUsageStat(itemName: "후드티", usageCount: 3),
                ItemUsageStat(itemName: "레깅스", usageCount: 2)
            ],
            showingTooltip: .constant(nil)
        ) {}
    }
    .background(Color.Codive.grayscale7)
}

#Preview("값 차이 큰 케이스") {
    ScrollView {
        ItemStatsSection(
            stats: [
                ItemUsageStat(itemName: "티셔츠", usageCount: 20),
                ItemUsageStat(itemName: "셔츠", usageCount: 5),
                ItemUsageStat(itemName: "니트", usageCount: 3),
                ItemUsageStat(itemName: "후드티", usageCount: 2),
                ItemUsageStat(itemName: "맨투맨", usageCount: 1)
            ],
            showingTooltip: .constant(nil)
        ) {}
    }
    .background(Color.Codive.grayscale7)
}
