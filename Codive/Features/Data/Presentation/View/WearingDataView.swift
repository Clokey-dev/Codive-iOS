//
//  WearingDataView.swift
//  Codive
//
//  Created by 한태빈 on 12/19/25.
//

import SwiftUI

struct WearingDataView: View {
    let stats: WardrobeUsageStat
    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: DonutSegment.ID? = nil

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "활용도 체크") {
                dismiss()
            }
            .background(Color.Codive.grayscale7)

            Text("보관 중인 가을 옷 \(stats.totalCount)벌 중\n\(stats.wornCount)벌을 실제로 입었어요")
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale3)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.bottom, 30)
            usageChart

            Spacer(minLength: 0)
        }
        .background(Color("white"))
        .navigationBarHidden(true)
    }

    private var usageChart: some View {
        let safeTotal = max(0, stats.totalCount)
        let safeWorn = max(0, min(stats.wornCount, safeTotal))
        let notWorn = max(0, safeTotal - safeWorn)

        let segments: [DonutSegment] = [
            DonutSegment(value: Double(safeWorn), color: Color.Codive.point1, payload: "입음"),
            DonutSegment(value: Double(notWorn), color: Color(red: 0.97, green: 0.92, blue: 0.86), payload: "미착용")
        ]

        return DonutChartView(
            segments: segments,
            selectedID: $selectedID,
            thickness: 45,
            gapDegrees: 0
        ) {
            Text("\(stats.usagePercent)%")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.Codive.point1)
        }
        .frame(width: 196, height: 196)
        .onAppear {
            selectedID = nil
        }
    }
}
// MARK: - Preview
#Preview {
    WearingDataView(stats: WardrobeUsageStat(totalCount: 30, wornCount: 12))
}
