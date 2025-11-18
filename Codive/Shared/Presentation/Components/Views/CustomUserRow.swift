//
//  CustomUserRow.swift
//  Codive
//
//  Created by 한태빈 on 10/6/25.
//

import SwiftUI

struct CustomUserRow: View {
    let user: SimpleUser           // 유저 정보
    let buttonTitle: String        // 오른쪽 버튼 텍스트
    let action: () -> Void         // 버튼 탭 액션

    var body: some View {
        HStack {
            // 아바타
            AsyncImage(url: user.avatarURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                case .empty: Color("Grayscale4")
                case .failure: Color("Grayscale4")
                @unknown default: Color("Grayscale4")
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            // 닉네임 / 아이디
            VStack(alignment: .leading, spacing: 2) {
                Text(user.nickname)
                    .font(.codive_body1_medium)
                    .foregroundStyle(Color("Grayscale1"))
                Text(user.handle)
                    .font(.codive_body3_medium)
                    .foregroundStyle(Color("Grayscale3"))
            }
            .padding(.leading, 8)

            Spacer()

            Button(action: action) {
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
    let dummy = SimpleUser(
        userId: 0,
        nickname: "닉네임",
        handle: "아이디",
        avatarURL: nil
    )

    VStack(spacing: 24) {
        CustomUserRow(user: dummy, buttonTitle: "팔로우") { }
        CustomUserRow(user: dummy, buttonTitle: "차단 해제") { }
    }
}
