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
    
    // Bottom Sheet
    @State private var isBottomSheetPresented = false
    @State private var bottomSheetTitle = ""
    @State private var bottomSheetItems: [DataBottomSheetClothItem] = []
    @State private var isFirstLoad = true

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
        .background(Color.white)
        .navigationBarHidden(true)
        .dataBottomSheet(
            isPresented: $isBottomSheetPresented,
            dataBottomSheetTitle: bottomSheetTitle,
            totalCount: bottomSheetItems.count,
            items: bottomSheetItems
        )
    }

    private var usageChart: some View {
        let safeTotal = max(0, stats.totalCount)
        let safeWorn = max(0, min(stats.wornCount, safeTotal))
        let notWorn = max(0, safeTotal - safeWorn)

        let segments: [DonutSegment] = [
            DonutSegment(value: Double(safeWorn), color: Color.Codive.point1, payload: "입음"),
            DonutSegment(value: Double(notWorn), color: Color.Codive.point4, payload: "미착용")
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
        .onChange(of: selectedID) { newValue in
            // 초기 로딩이나 선택 해제(nil) 시 무시
            if isFirstLoad {
                isFirstLoad = false
                return
            }
            guard let id = newValue else { return }
            
            if let seg = segments.first(where: { $0.id == id }) {
                let payload = seg.payload ?? ""
                if payload == "입음" {
                    bottomSheetTitle = "\(safeWorn)벌 착용"
                    bottomSheetItems = makeMockItems(count: safeWorn)
                } else if payload == "미착용" {
                    bottomSheetTitle = "\(notWorn)벌 미착용"
                    bottomSheetItems = makeMockItems(count: notWorn)
                }
                isBottomSheetPresented = true
            }
        }
    }
    
    private func makeMockItems(count: Int) -> [DataBottomSheetClothItem] {
        (0..<count).map { i in
            DataBottomSheetClothItem(
                imageName: "samplecloth",
                brand: "MockBrand",
                title: "Wearing Item \(i + 1)"
            )
        }
    }
}
// MARK: - Preview
#Preview {
    WearingDataView(stats: WardrobeUsageStat(totalCount: 30, wornCount: 12))
}
