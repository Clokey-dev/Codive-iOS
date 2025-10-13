//
//  CodiBoardView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct CodiBoardView: View {
    var body: some View {
        CustomNavigationBar(title: "코디보드") {
            print("뒤로가기")
        }
        ScrollView {
            VStack {
                Text("옷을 자유롭게 배치해 스타일을 살펴보세요.")
                    .font(Font.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.Codive.grayscale7)
                    .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.Codive.grayscale5, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                    .padding(.horizontal, 20)
                
                CustomButton(text: "이 코디로 결정하기", widthType: .half) {
                    print("이 코디로 결정하기 tapped")
                }
                .padding(.horizontal, 20)
                .padding(.top, 205)
            }
        }
        
    }
}

#Preview {
    CodiBoardView()
}
