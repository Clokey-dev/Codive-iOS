//
//  CustomButton.swift
//  Codive
//
//  Created by 한금준 on 10/4/25.
//

import SwiftUI

enum ButtonType {
    case fixed
    case dynamic
    case half
}

struct CustomButton: View {
    let text: String
    let widthType: ButtonType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(Font.codive_title2)
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .modifier(WidthModifier(type: widthType))
        .frame(height: 48)
        .background(Color.Codive.main0)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
     }
}

struct WidthModifier: ViewModifier {
    let type: ButtonType

    func body(content: Content) -> some View {
        switch type {
        case .fixed:
            content
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
        case .dynamic:
            content
                .padding(.horizontal, 16)
        case .half:
            content
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        /// 1. 6.  화면 전체 너비 버튼
        CustomButton(text: "이 코디로 결정하기", widthType: .fixed) {
            print("이 코디 결정 tapped!")
        }

        /// 5. 고정크기 버튼
        CustomButton(text: "피드 작성하러 가기", widthType: .dynamic) {
            print("피드작성 tapped!")
        }
    }
    .padding()

    /// 3. 4. 화면 전체 너비 1/2
    HStack(spacing: 9) {
        CustomButton(text: "이전으로", widthType: .half) {
            print("이전으로 tapped")
        }
        CustomButton(text: "등록하기", widthType: .half) {
            print("등록하기 tapped")
        }
    }
    .padding(.horizontal, 20)

    /// 2. 서로 다른 너비
    HStack(spacing: 16) {
        CustomButton(text: "코디보드", widthType: .dynamic) {
            print("코디보드 tapped")
        }

        CustomButton(text: "이 코디로 결정하기", widthType: .dynamic) {
            print("이 코디 결정 tapped")
        }
    }
    .padding()
}
