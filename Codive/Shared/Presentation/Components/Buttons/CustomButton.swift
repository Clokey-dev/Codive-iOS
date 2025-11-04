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
    case outlinedHalf
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
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: borderWidth)
        )
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
        case .dynamic:
            content
                .padding(.horizontal, 16)
        case .half, .outlinedHalf:
            content
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        /// 1. 6. 화면 전체 너비 버튼
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
    
    HStack(spacing: 9) {
        CustomButton(text: "취소", widthType: .outlinedHalf) {
            print("취소 tapped")
        }
        CustomButton(text: "확인", widthType: .half) {
            print("확인 tapped")
        }
    }
    .padding(.horizontal, 20)
}
