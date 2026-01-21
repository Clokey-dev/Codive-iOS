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
            Spacer(minLength: 0)
            
            VStack(spacing: 0) {
                Capsule()
                    .foregroundStyle(Color("Grayscale5"))
                    .frame(width: 69, height: 4)
                    .padding(.top, 11)
                    .padding(.bottom, 33)
                
                Button(action: action1) {
                    HStack(spacing: 16) {
                        Image(iconName1)
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text(title1)
                            .font(.codive_title3)
                            .foregroundStyle(Color("Grayscale1"))
                        
                        Spacer()
                        
                        Image("backSmall")
                            .resizable()
                            .frame(width: 8, height: 13)
                            .rotationEffect(.degrees(180))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                Button(action: action2) {
                    HStack(spacing: 14) {
                        Image(iconName2)
                            .resizable()
                            .frame(width: 25, height: 25)
                        
                        Text(title2)
                            .font(.codive_title3)
                            .foregroundStyle(Color("Grayscale1"))
                        
                        Spacer()
                        
                        Image("backSmall")
                            .resizable()
                            .frame(width: 8, height: 13)
                            .rotationEffect(.degrees(180))
                    }
                }
                .padding(.leading, 18)
                .padding(.trailing, 20)
                .padding(.bottom, 56)
            }
            .background(Color.white)
            .clipShape(
                RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
            )
        }
        .ignoresSafeArea(edges: .bottom)
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
