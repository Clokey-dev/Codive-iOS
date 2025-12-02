//
//  SelectionButtonStyle.swift
//  Codive
//
//  Created by Gemini on 2025/12/01.
//

import SwiftUI

struct SelectionButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.codive_body2_medium)
            .foregroundStyle(isSelected ? Color.Codive.point1 : Color.Codive.grayscale1)
            .padding(.horizontal, 14) // Added padding
            .padding(.vertical, 7)    // Added padding
            .background(isSelected ? Color.Codive.point4 : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(isSelected ? Color.Codive.point2 : Color.Codive.grayscale5, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 100))
    }
}
