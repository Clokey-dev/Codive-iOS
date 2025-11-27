//
//  CustomCategoryTag.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import SwiftUI

struct CustomCategoryTag: View {
    
    // MARK: - Properties
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.codive_body2_medium)
                .foregroundStyle(isSelected ? Color.Codive.point1 : Color.Codive.grayscale1)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.Codive.point4 : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(isSelected ? Color.Codive.point2 : Color.Codive.grayscale5, lineWidth: isSelected ? 2 : 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 100))
        }
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 8) {
        CustomCategoryTag(title: "전체", isSelected: true) { }
        CustomCategoryTag(title: "상의", isSelected: false) { }
        CustomCategoryTag(title: "바지", isSelected: false) { }
    }
    .padding(20)
}
