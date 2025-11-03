//
//  SettingLikedView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct SettingLikedView: View {
    var body: some View {
        CustomNavigationBar(title: "좋아요 한 기록") {
            print("뒤로가기")
        }
        Spacer()
        Text("아직 좋아요한 기록이 없어요!")
            .font(.codive_title2)
            .foregroundStyle(Color("Grayscale1"))
            .padding(.bottom, 8)
        Text("지금 하나 눌러볼까요?")
            .font(.codive_body2_regular)
            .foregroundStyle(Color("Grayscale1"))
            .padding(.bottom, 24)
        CustomButton(text: "피드로 이동하기", widthType: .dynamic) {
            print("피드 lets go")
        }
        Spacer()
    }
}

#Preview {
    SettingLikedView()
}
