//
//  AddOptionButton.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI

struct AddOptionButton: View {
    let iconName: String
    let iconBackgroundColor: Color
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 아이콘 영역
                Image(iconName)
                   .resizable()
                   .scaledToFit()
                   .frame(width: 25, height: 25)
                
                // 텍스트 영역
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.codive_body1_medium)
                        .foregroundColor(.Codive.grayscale1)
                    
                    Text(description)
                        .font(.codive_body2_medium)
                        .foregroundColor(.Codive.grayscale3)
                }
                
                Spacer()
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 15)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AddOptionButton(
            iconName: "ai_icon",
            iconBackgroundColor: .orange,
            title: "AI 자동추가",
            description: "이미지를 업로드하면 옷이 자동으로 등록돼요"
        ) {
            print("AI 자동추가 탭")
        }
        
        AddOptionButton(
            iconName: "cloth_icon",
            iconBackgroundColor: .orange,
            title: "직접 추가",
            description: "옷을 직접 추가하여 나만의 옷장을 만들어요"
        ) {
            print("직접 추가 탭")
        }
        
        AddOptionButton(
            iconName: "feed_icon",
            iconBackgroundColor: .orange,
            title: "기록 추가",
            description: "오늘의 스타일을 기록해요"
        ) {
            print("기록 추가 탭")
        }
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
