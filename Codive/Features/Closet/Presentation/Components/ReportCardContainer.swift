//
//  ReportCardContainer.swift
//  Codive
//
//  Created by 황상환 on 5/5/26.
//

import SwiftUI

struct ReportCardContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.Codive.grayscale6, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    ReportCardContainer {
        Text("리포트 카드 콘텐츠")
            .font(.codive_body2_medium)
            .foregroundStyle(Color.Codive.grayscale1)
            .frame(height: 120)
    }
    .padding(.vertical, 40)
    .background(Color.Codive.grayscale7)
}
