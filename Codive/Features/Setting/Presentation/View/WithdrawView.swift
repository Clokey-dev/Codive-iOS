//
//  WithdrawView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct WithdrawView: View {
    var body: some View {
        CustomNavigationBar(title: "계정 탈퇴") {
            print("뒤로가기")
        }
        VStack {
            HStack {
                Image("warning")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 20)
                
                Text("탈퇴 전 아래 내용을 확인해주세요")
                    .font(.codive_title2)
                    .foregroundStyle(Color("Grayscale1"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 32)
            
            Image("withdraw1")
                .resizable()
                .scaledToFit()
                .padding(.bottom, 12)
                .padding(.horizontal, 20)
            
            Image("withdraw2")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 20)

            Spacer()
            
            CustomButton(text: "계정 탈퇴하기", widthType: .fixed) {
                print("신고 lets go")
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    WithdrawView()
}
