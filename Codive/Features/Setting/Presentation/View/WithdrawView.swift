//
//  WithdrawView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct WithdrawView: View {
    var body: some View {
        CustomNavigationBar(title: TextLiteral.Setting.withdrawTitle) {
            print("뒤로가기")
        }
        VStack {
            HStack {
                Image("orangeWarning")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 20)

                Text(TextLiteral.Setting.withdrawNotice)
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
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

            CustomButton(text: TextLiteral.Setting.withdrawButton, widthType: .fixed) {
                print("계정 탈퇴하기")
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    WithdrawView()
}
