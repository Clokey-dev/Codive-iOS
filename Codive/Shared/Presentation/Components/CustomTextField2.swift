//
//  CustomTextField2.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

struct CustomTextField2: View {
    
    // MARK: - Properties
    let title: String
    let placeholder: String
    @Binding var text: String
    let showRequiredMark: Bool
    let buttonTitle: String?
    let onButtonTap: (() -> Void)?
    let helperText: String?
    let helperTextColor: Color
    
    // MARK: - Initializer
    init(
        title: String,
        placeholder: String = "",
        text: Binding<String>,
        showRequiredMark: Bool = false,
        buttonTitle: String? = nil,
        onButtonTap: (() -> Void)? = nil,
        helperText: String? = nil,
        helperTextColor: Color = Color.Codive.grayscale4
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.showRequiredMark = showRequiredMark
        self.buttonTitle = buttonTitle
        self.onButtonTap = onButtonTap
        self.helperText = helperText
        self.helperTextColor = helperTextColor
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            HStack(spacing: 4) {
                Text(title)
                    .font(.codive_title3)
                    .foregroundColor(Color.Codive.grayscale1)
                
                if showRequiredMark {
                    Text("*")
                        .font(.codive_title3)
                        .foregroundColor(Color.Codive.point1)
                }
            }
            .padding(.bottom, 8)
            
            // TextField + Button
            HStack(spacing: 8) {
                TextField(placeholder, text: $text)
                    .font(.codive_body2_regular)
                    .foregroundColor(Color.Codive.grayscale1)
                    .frame(height: 28)
                
                if let buttonTitle = buttonTitle {
                    Button {
                        onButtonTap?()
                    } label: {
                        Text(buttonTitle)
                            .font(.codive_body2_medium)
                            .foregroundColor(Color.Codive.grayscale1)
                            .frame(width: 72, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(Color.Codive.grayscale4, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.bottom, 2)
            
            // Bottom Line
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
            
            // Helper Text
            if let helperText = helperText {
                Text(helperText)
                    .font(.codive_body2_regular)
                    .foregroundColor(helperTextColor)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 32) {
        // 기본 형태 (버튼 없음)
        CustomTextField2(
            title: "닉네임",
            placeholder: "집에가자",
            text: .constant(""),
            showRequiredMark: true,
            helperText: "사용 가능한 닉네임 입니다."
        )
        
        // 버튼 + 안내문구
        CustomTextField2(
            title: "아이디",
            placeholder: "",
            text: .constant("dksdbs12"),
            showRequiredMark: true,
            buttonTitle: "중복 확인",
            onButtonTap: {
                print("중복 확인 버튼 탭")
            },
            helperText: "사용 가능한 아이디 입니다."
        )
        
        // 에러 상태
        CustomTextField2(
            title: "닉네임",
            placeholder: "",
            text: .constant("집에가고싶어요"),
            showRequiredMark: true,
            helperText: "6글자 이내로 입력해주세요.",
            helperTextColor: Color.Codive.point1
        )
        
        // 성공 상태 (버튼 포함)
        CustomTextField2(
            title: "아이디",
            placeholder: "",
            text: .constant("cky11"),
            showRequiredMark: true,
            buttonTitle: "중복 확인",
            onButtonTap: {
                print("중복 확인 버튼 탭")
            },
            helperText: "이미 사용중인 아이디입니다.",
            helperTextColor: Color.Codive.point1
        )
        
        // 한줄소개 (버튼 없음, 필수 아님)
        CustomTextField2(
            title: "한줄소개",
            placeholder: "20자 이내로 나를 소개 해보세요",
            text: .constant("")
        )
    }
    .padding(.horizontal, 20)
    .background(Color.white)
}
