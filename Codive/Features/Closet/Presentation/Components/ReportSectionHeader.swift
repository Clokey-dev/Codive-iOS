//
//  ReportSectionHeader.swift
//  Codive
//
//  Created by 황상환 on 5/5/26.
//

import SwiftUI

// MARK: - ReportSectionHeader

struct ReportSectionHeader: View {

    let title: String
    let tooltip: String
    @Binding var showingTooltip: String?

    private var isShown: Bool { showingTooltip == tooltip }

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingTooltip = isShown ? nil : tooltip
                }
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.Codive.grayscale4)
            }
            // 페이지 루트가 받아서 모든 카드 위에 띄울 수 있도록 ⓘ 버튼 위치를 anchor로 전달
            .anchorPreference(key: TooltipAnchorKey.self, value: .bounds) { anchor in
                isShown ? TooltipAnchor(text: tooltip, anchor: anchor) : nil
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - PreferenceKey

struct TooltipAnchor: Equatable {
    let text: String
    let anchor: Anchor<CGRect>

    static func == (lhs: TooltipAnchor, rhs: TooltipAnchor) -> Bool {
        lhs.text == rhs.text
    }
}

struct TooltipAnchorKey: PreferenceKey {
    static var defaultValue: TooltipAnchor?
    static func reduce(value: inout TooltipAnchor?, nextValue: () -> TooltipAnchor?) {
        value = value ?? nextValue()
    }
}

// MARK: - TooltipBubbleView

struct TooltipBubbleView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.codive_body3_regular)
            .foregroundStyle(Color.Codive.grayscale3)
            .multilineTextAlignment(.leading)
            .lineSpacing(4)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.Codive.grayscale6)
            )
    }
}

// MARK: - Preview

#Preview("툴팁 닫힘") {
    ReportSectionHeader(
        title: "옷장 아이템 통계",
        tooltip: "전체 아이템 중 많이 보유한 아이템\nTOP 5를 확인할 수 있는 그래프입니다",
        showingTooltip: .constant(nil)
    )
    .padding(.vertical, 16)
    .background(Color.Codive.grayscale7)
}

#Preview("툴팁 단독") {
    TooltipBubbleView(text: "전체 아이템 중 많이 보유한 아이템\nTOP 5를 확인할 수 있는 그래프입니다")
        .padding()
        .background(Color.Codive.grayscale7)
}
