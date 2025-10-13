//
//  AddView.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import SwiftUI

struct AddView: View {
    var body: some View {
        VStack(spacing: 0) {
            // 상단 타이틀
            Text(TextLiteral.Add.mainTitle)
                .font(.codive_title1)
                .padding(.top, 20)
            
            // 질문 텍스트
            Text(TextLiteral.Add.questionTitle)
                .font(.codive_title1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 38)
                .padding(.bottom, 24)
                .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 24) {
                    // 옷 추가 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text(TextLiteral.Add.clothesSectionTitle)
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            AddOptionButton(
                                iconName: "ai_icon",
                                iconBackgroundColor: .orange,
                                title: TextLiteral.Add.aiAutoAddTitle,
                                description: TextLiteral.Add.aiAutoAddDescription
                            ) {
                                // AI 자동추가 액션
                            }
                            
                            AddOptionButton(
                                iconName: "cloth_icon",
                                iconBackgroundColor: .orange,
                                title: TextLiteral.Add.manualAddTitle,
                                description: TextLiteral.Add.manualAddDescription
                            ) {
                                // 직접 추가 액션
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom,48)
                    
                    // 기록 추가 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text(TextLiteral.Add.recordSectionTitle)
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 20)
                        
                        AddOptionButton(
                            iconName: "feed_icon",
                            iconBackgroundColor: .orange,
                            title: TextLiteral.Add.recordAddTitle,
                            description: TextLiteral.Add.recordAddDescription
                        ) {
                            // 기록 추가 액션
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            Spacer()
        }
        .background(Color.white)
    }
}

#Preview {
    AddView()
}
