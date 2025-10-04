//
//  CustomTestView.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

struct CustomTestView: View {
    var body: some View {
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
}

#Preview {
    CustomTestView()
}
