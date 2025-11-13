//
//  CustomButton.swift
//  Codive
//
//  Created by 한금준 on 10/4/25.
//

import SwiftUI

enum ButtonWidthType {
    case fixed
    case dynamic
    case half
}

enum ButtonStyleType {
    case fill
    case border
}

struct CustomButton: View {
    let text: String
    let widthType: ButtonWidthType
    var styleType: ButtonStyleType = .fill
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(Font.codive_title2)
                .padding()
                .modifier(TextStyleModifier(type: styleType, isEnabled: isEnabled))
        }
        .modifier(WidthModifier(type: widthType))
        .frame(height: 48)
        .modifier(ButtonStyleModifier(type: styleType, isEnabled: isEnabled))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
        .disabled(!isEnabled)
    }
}

struct WidthModifier: ViewModifier {
    let type: ButtonWidthType

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

struct TextStyleModifier: ViewModifier {
    let type: ButtonStyleType
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        switch type {
        case .fill:
            content.foregroundStyle(isEnabled ? .white : Color.white)
        case .border:
            content.foregroundStyle(isEnabled ? Color.Codive.main0 : Color.white)
        }
    }
}

struct ButtonStyleModifier: ViewModifier {
    let type: ButtonStyleType
    let isEnabled: Bool

    func body(content: Content) -> some View {
        switch type {
        case .fill:
            content
                .background(alignment: .center) {
                    isEnabled ? Color.Codive.main0 : Color.Codive.main3
                }
        case .border:
            content
                .background(alignment: .center) {
                    Color.white
                }
                .overlay(alignment: .center) {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isEnabled ? Color.Codive.main0 : Color.Codive.grayscale4, lineWidth: 1)
                }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 활성화된 버튼
        CustomButton(text: "이 코디로 결정하기 (활성화)", widthType: .fixed) {
            print("이 코디 결정 tapped!")
        }
        
        // 비활성화된 버튼
        CustomButton(text: "이 코디로 결정하기 (비활성화)", widthType: .fixed, isEnabled: false) {
            print("이 코디 결정 tapped!")
        }

        CustomButton(text: "피드 작성하러 가기 (Border)", widthType: .dynamic, styleType: .border) {
            print("피드작성 tapped!")
        }
        
        CustomButton(text: "피드 작성하러 가기 (Border 비활성화)", widthType: .dynamic, styleType: .border, isEnabled: false) {
            print("피드작성 tapped!")
        }
    }
    .padding()

    HStack(spacing: 9) {
        CustomButton(text: "이전으로", widthType: .half) {
            print("이전으로 tapped")
        }
        CustomButton(text: "등록하기 (비활성화)", widthType: .half, isEnabled: false) {
            print("등록하기 tapped")
        }
    }
    .padding(.horizontal, 20)
}
