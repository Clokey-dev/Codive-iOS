//
//  SettingCommentView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct SettingCommentView: View {
    var body: some View {
        CustomNavigationBar(title: "설정") {
            print("뒤로가기")
        }
        Spacer()
        Text("아직 남긴 댓글이 없어요!")
            .font(.codive_title2)
            .foregroundStyle(Color("Grayscale1"))
            .padding(.bottom, 8)
        Text("지금 하나 써볼까요?")
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
    SettingCommentView()
}
