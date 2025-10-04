//
//  CustomTestView.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

struct CustomTestView: View {
    var body: some View {
        VStack(spacing: 24) {
            CustomTextField1(
                title: "계절",
                placeholder: "봄",
                text: .constant(""),
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
}

#Preview {
    CustomTestView()
}
