//
//  UsageCheckSection.swift
//  Codive
//
//  Created by 황상환 on 5/5/26.
//

import SwiftUI

struct UsageCheckSection: View {

    let usage: WardrobeUsageStat
    var topItemName: String?
    @Binding var showingTooltip: String?
    let onTap: () -> Void

    private var infoText: String {
        if let name = topItemName, !name.isEmpty {
            return "\(name)이 가장 많으며\n총 \(usage.wornCount)번 착용했습니다"
        }
        return "총 \(usage.totalCount)벌 중\n\(usage.wornCount)번 착용했습니다"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ReportSectionHeader(
                title: "옷장 활용도 체크",
                tooltip: "코디 결정하기와 기록에서 태그한 옷을 기반으로\n보관 중인 옷 중 실제 착용한 비율을 보여주는 그래프입니다",
                showingTooltip: $showingTooltip
            )

            ReportCardContainer {
                HStack(alignment: .center, spacing: 32) {
                    VStack(spacing: 8) {
                        UsageDonutChart(stats: usage)
                            .frame(width: 130, height: 130)

                        (Text("(\(usage.wornCount)벌").foregroundColor(Color.Codive.point1)
                            + Text(" / \(usage.totalCount)벌)").foregroundColor(Color.Codive.grayscale3))
                            .font(.codive_body3_medium)
                    }

                    Text(infoText)
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale3)
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 4)
            }
            .onTapGesture { onTap() }
        }
    }
}

// MARK: - Preview

#Preview("디자인 매칭 - 40%") {
    ScrollView {
        UsageCheckSection(
            usage: WardrobeUsageStat(totalCount: 20, wornCount: 8),
            topItemName: "나시",
            showingTooltip: .constant(nil)
        ) {}
    }
    .background(Color.Codive.grayscale7)
}

#Preview("70% 활용") {
    ScrollView {
        UsageCheckSection(
            usage: WardrobeUsageStat(totalCount: 30, wornCount: 21),
            topItemName: "맨투맨",
            showingTooltip: .constant(nil)
        ) {}
    }
    .background(Color.Codive.grayscale7)
}

#Preview("100% 활용") {
    ScrollView {
        UsageCheckSection(
            usage: WardrobeUsageStat(totalCount: 15, wornCount: 15),
            topItemName: "셔츠",
            showingTooltip: .constant(nil)
        ) {}
    }
    .background(Color.Codive.grayscale7)
}

#Preview("topItem 없음") {
    ScrollView {
        UsageCheckSection(
            usage: WardrobeUsageStat(totalCount: 50, wornCount: 30),
            showingTooltip: .constant(nil)
        ) {}
    }
    .background(Color.Codive.grayscale7)
}
