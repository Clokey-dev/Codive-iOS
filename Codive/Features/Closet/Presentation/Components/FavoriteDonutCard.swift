//
//  FavoriteDonutCard.swift
//  Codive
//
//  Created by 황상환 on 5/5/26.
//

import SwiftUI

struct FavoriteDonutCard: View {

    let categoryTitle: String
    let segments: [DonutSegment]

    @State private var selectedID: DonutSegment.ID?

    private var total: Double {
        segments.map(\.value).reduce(0, +)
    }

    private var selectedPercentText: String {
        guard let selectedID,
              let seg = segments.first(where: { $0.id == selectedID }),
              total > 0
        else { return "" }
        let percent = Int(round((seg.value / total) * 100))
        return "\(percent)%"
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 35) {
                ZStack {
                    DonutChartView(
                        segments: segments,
                        selectedID: $selectedID,
                        thickness: 28,
                        gapDegrees: 0,
                        cornerRadius: 6
                    ) {
                        Text(categoryTitle)
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                    }
                    .frame(width: 116, height: 116)
                    // 도넛 자체 탭으로 segment 강조 변경되지 않게 비활성화 (카드 전체 탭으로 상세 이동)
                    .allowsHitTesting(false)

                    if !selectedPercentText.isEmpty {
                        PercentBubbleView(text: selectedPercentText)
                            .offset(x: 34, y: -40)
                            .allowsHitTesting(false)
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(segments, id: \.id) { row in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(row.color)
                                .frame(width: 14, height: 14)

                            if let name = row.payload {
                                Text(name)
                                    .font(.codive_body2_medium)
                                    .foregroundStyle(Color.Codive.grayscale1)
                            }
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.Codive.grayscale4)
                .padding(.trailing, 14)
                .padding(.top, 16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.Codive.grayscale6, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .onAppear {
            selectedID = segments.first?.id
        }
    }
}

// MARK: - PercentBubbleView

private struct PercentBubbleView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.codive_body3_medium)
            .foregroundStyle(Color.Codive.grayscale1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                SpeechBubbleShape()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
    }
}

// MARK: - Preview

#Preview("상의 - 4개 항목") {
    FavoriteDonutCard(
        categoryTitle: "상의",
        segments: [
            DonutSegment(value: 45, color: .Codive.point1, payload: "맨투맨"),
            DonutSegment(value: 30, color: .Codive.point2, payload: "후드티"),
            DonutSegment(value: 15, color: .Codive.point3, payload: "셔츠"),
            DonutSegment(value: 10, color: .Codive.grayscale5, payload: "기타")
        ]
    )
    .frame(width: 300, height: 182)
    .padding()
    .background(Color.Codive.grayscale7)
}

#Preview("하의 - 2개 항목") {
    FavoriteDonutCard(
        categoryTitle: "하의",
        segments: [
            DonutSegment(value: 70, color: .Codive.point1, payload: "청바지"),
            DonutSegment(value: 30, color: .Codive.point2, payload: "면바지")
        ]
    )
    .frame(width: 300, height: 182)
    .padding()
    .background(Color.Codive.grayscale7)
}
