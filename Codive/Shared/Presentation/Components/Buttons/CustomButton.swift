// CustomButton.swift

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
                .modifier(TextStyleModifier(type: styleType))
        }
        .modifier(WidthModifier(type: widthType))
        .frame(height: 48)
        .modifier(ButtonStyleModifier(type: styleType))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
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
    
    func body(content: Content) -> some View {
        switch type {
        case .fill:
            content.foregroundColor(.white)
        case .border:
            content.foregroundColor(Color.Codive.main0)
        }
    }
}

struct ButtonStyleModifier: ViewModifier {
    let type: ButtonStyleType

    func body(content: Content) -> some View {
        switch type {
        case .fill:
            content
                .background(Color.Codive.main0)
        case .border:
            content
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.Codive.main0, lineWidth: 1)
                )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomButton(text: "이 코디로 결정하기 (Default Fill)", widthType: .fixed) {
            print("이 코디 결정 tapped!")
        }

        CustomButton(text: "피드 작성하러 가기 (Border)", widthType: .dynamic, styleType: .border) {
            print("피드작성 tapped!")
        }
    }
    .padding()

    HStack(spacing: 9) {
        CustomButton(text: "이전으로 (Default Fill)", widthType: .half) {
            print("이전으로 tapped")
        }
        CustomButton(text: "등록하기 (Border)", widthType: .half, styleType: .border) {
            print("등록하기 tapped")
        }
    }
    .padding(.horizontal, 20)
}
