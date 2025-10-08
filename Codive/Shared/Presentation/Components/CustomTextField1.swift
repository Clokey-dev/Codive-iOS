//
//  CustomTextField1.swift
//  Codive
//
//  Created by 황상환 on 10/2/25.
//

import SwiftUI

struct CustomTextField1: View {
    
    // MARK: - Properties
    let title: String
    let placeholder: String
    @Binding var text: String
    
    // MARK: - Initializer
    init(
        title: String,
        placeholder: String = "",
        text: Binding<String>
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(title)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)
            
            // TextField
            TextField(placeholder, text: $text)
                .font(.codive_body1_regular)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.Codive.grayscale5, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .tint(Color.Codive.main1)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 24) {
        CustomTextField1(
            title: "계절",
            placeholder: "봄",
            text: .constant("")
        )
        
        CustomTextField1(
            title: "옷 이름",
            placeholder: "옷 이름을 입력해주세요.",
            text: .constant("")
        )
        
        CustomTextField1(
            title: "브랜드",
            placeholder: "브랜드를 입력해주세요.",
            text: .constant("나이키")
        )
    }
    .padding(.horizontal, 20)
    .background(Color.Codive.grayscale7)
}
