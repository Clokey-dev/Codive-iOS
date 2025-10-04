//
//  CustomTestView.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

struct CustomTestView: View {
    var body: some View {
        VStack(spacing: 40) {
            CustomMultiSelectButton(
                title: "오늘의 스타일을 선택해보세요",
                options: ["걸리시", "러블리", "미니멀", "빈티지", "스포티", "스트릿", "시크", "오피스룩", "캐주얼", "클래식", "하이틴"],
                selectedOptions: .constant(["걸리시", "스트릿", "시크"]),
                maxSelection: 3,
                showRequiredMark: true
            )
            
            CustomMultiSelectButton(
                title: "어떤 상황에 주로 입으시나요?",
                options: ["데이트", "데일리", "여행", "운동", "축제", "출근복", "파티"],
                selectedOptions: .constant(["데이트"]),
                maxSelection: nil,
                showRequiredMark: true
            )
        }
        .padding(.horizontal, 20)
        .background(Color.white)    }
}

#Preview {
    CustomTestView()
}
