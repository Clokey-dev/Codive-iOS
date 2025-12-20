//
//  EmptyStateView.swift
//  Codive
//
//  Created by 황상환 on 12/13/25.
//

import SwiftUI

struct EmptyStateView: View {
    
    // MARK: - Properties
    let headerTitle: String?
    let title: String
    let description: String
    let buttonText: String
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            if let headerTitle = headerTitle {
                Text(headerTitle)
                    .font(.codive_title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 80)
            } else {
                Spacer()
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)

                Text(description)
                    .font(.codive_body2_regular)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            
            CustomButton(
                text: buttonText,
                widthType: .dynamic,
                action: action
            )
            .padding(.top, 24)
            
            if headerTitle == nil {
                Spacer() 
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview("기본 옷장 예시") {
    EmptyStateView(
        headerTitle: "나의 옷장",
        title: "옷장이 비어있어요.",
        description: "옷을 추가해 나만의 디지털 옷장을 만들고,\n필요할 때 언제든 한눈에 확인하세요.",
        buttonText: "옷 추가하기",
        action: {}
    )
}

#Preview("리포트 예시") {
    EmptyStateView(
        headerTitle: "나의 리포트",
        title: "아직 분석 결과가 없어요.",
        description: "옷을 추가해 나만의 옷 리포트를 받아보세요. 옷장 인사이트를 얻을 수 있어요.",
        buttonText: "옷 추가하기",
        action: {}
    )
}
