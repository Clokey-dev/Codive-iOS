//
//  CustomUserRow.swift
//  Codive
//
//  Created by 한태빈 on 10/6/25.
//

import SwiftUI

struct CustomUserRow: View {
    let buttonTitle: String
    var body: some View {
            HStack {
                Image("CustomProfile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("닉네임")
                        .font(.codive_body1_medium)
                        .foregroundStyle(Color("Grayscale1"))
                    Text("아이디")
                        .font(.codive_body3_medium)
                        .foregroundStyle(Color("Grayscale3"))
                }
                .padding(.leading, 8)
                
                Spacer()
                
                Button {
                    // action
                } label: {
                    Text(buttonTitle)
                        .font(.codive_body2_medium)
                        .foregroundStyle(.white)
                        .frame(minWidth: 76, minHeight: 32)
                        .background(Color("main0"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
    }
}

#Preview {
    CustomUserRow(
        buttonTitle: "팔로우"
    )
    .padding(.bottom, 24)
    CustomUserRow(
        buttonTitle: "차단해제"
    )
}
