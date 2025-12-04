//
//  CustomBottomSheet.swift
//  Codive
//
//  Created by 한태빈 on 10/6/25.
//

import SwiftUI

struct CustomBottomSheet: View {
    let iconName1: String
    let iconName2: String
    let title1: String
    let title2: String
    let action1: () -> Void
    let action2: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .foregroundStyle(Color("Grayscale5"))
                .frame(width: 69, height: 4)
                .padding(.bottom, 33)
                .padding(.top, 11)
            Button(action: action1) {
                HStack(spacing: 16) {
                    Image(iconName1)
                        .frame(width: 36, height: 36)
                        .foregroundStyle(Color("main0"))
                    
                    Text(title1)
                        .font(.codive_title3)
                        .foregroundStyle(Color("Grayscale1"))
                    
                    Spacer()
                    
                    Image("backSmall")
                        .foregroundStyle(Color("main0"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Row 2 (이전 코디 불러오기)
            Button(action: action2) {
                HStack(spacing: 16) {
                    Image(iconName2)
                        .frame(width: 36, height: 36)
                        .foregroundStyle(Color("main0"))
                    
                    Text(title2)
                        .font(.codive_title3)
                        .foregroundStyle(Color("Grayscale1"))
                    
                    Spacer()
                    
                    Image("backSmall")
                        .foregroundStyle(Color("main0"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 56)
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
    }
}

#Preview {
    CustomBottomSheet(
        iconName1: "plus",
        iconName2: "clo_selected",
        title1: "새로운 코디 추가하기",
        title2: "이전 코디 불러오기",
        action1: { print("Action 1 tapped") },
        action2: { print("Action 2 tapped") }
    )
    .background(Color.gray.opacity(0.2))
}
