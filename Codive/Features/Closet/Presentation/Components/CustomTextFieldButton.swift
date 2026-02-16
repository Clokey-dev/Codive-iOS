//
//  CustomTextFieldButton.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

// MARK: - CustomTextFieldButton
struct CustomTextFieldButton: View {
    let title: String
    let value: String
    let placeholder: String
    let showRequiredMark: Bool
    let showError: Bool
    let action: () -> Void

    init(
        title: String,
        value: String,
        placeholder: String = "",
        showRequiredMark: Bool = false,
        showError: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.value = value
        self.placeholder = placeholder
        self.showRequiredMark = showRequiredMark
        self.showError = showError
        self.action = action
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            HStack(alignment: .top, spacing: 4) {
                Text(title)
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)

                if showRequiredMark {
                    Text("*")
                        .font(.codive_title2)
                        .foregroundStyle(Color.Codive.point1)
                        .offset(x: -4, y: -4)
                }
            }

            // Button (TextField 스타일)
            Button(action: action) {
                HStack {
                    Text(value.isEmpty ? placeholder : value)
                        .font(.codive_body1_regular)
                        .foregroundStyle(value.isEmpty ? Color.Codive.grayscale4 : Color.Codive.grayscale1)

                    Spacer()

                    if showError {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.red)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.Codive.grayscale3)
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            showError ? .red : Color.Codive.grayscale5,
                            lineWidth: showError ? 1.5 : 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
