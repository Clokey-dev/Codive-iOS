//
//  CustomUserRow.swift
//  Codive
//
//  Created by 한태빈 on 10/6/25.
//

import SwiftUI

enum CustomUserRowButtonStyle {
    case primary    // 채워진 스타일 (e.g. 팔로우)
    case secondary  // 테두리 스타일 (e.g. 팔로잉, 차단 해제)
    case none       // 버튼이 없는 상태
}

struct CustomUserRow: View {
    let user: SimpleUser
    let buttonTitle: String?
    let buttonStyle: CustomUserRowButtonStyle
    let action: () -> Void
    
    // MARK: - Convenience Initializers
    
    /// 버튼이 있는 경우 (팔로우 / 팔로잉 / 차단 해제 등)
    init(
        user: SimpleUser,
        buttonTitle: String,
        buttonStyle: CustomUserRowButtonStyle,
        action: @escaping () -> Void
    ) {
        self.user = user
        self.buttonTitle = buttonTitle
        self.buttonStyle = buttonStyle
        self.action = action
    }
    
    /// 버튼이 없는 경우
    init(
        user: SimpleUser,
        buttonStyle: CustomUserRowButtonStyle = .none,
        action: @escaping () -> Void
    ) {
        self.user = user
        self.buttonTitle = nil
        self.buttonStyle = buttonStyle
        self.action = action
    }

    // MARK: - Body
    
    var body: some View {
        HStack {
            // 아바타
            AsyncImage(url: user.avatarURL) { phase in
                switch phase {
                case .success(let img):
                    img
                        .resizable()
                        .scaledToFill()
                case .empty:
                    Color.Codive.grayscale4
                case .failure:
                    Color.Codive.grayscale4
                @unknown default:
                    Color.Codive.grayscale4
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            // 닉네임 / 아이디
            VStack(alignment: .leading, spacing: 2) {
                Text(user.nickname)
                    .font(.codive_body1_medium)
                    .foregroundStyle(Color.Codive.grayscale1)
                if !user.handle.isEmpty {
                    Text(user.handle)
                        .font(.codive_body3_medium)
                        .foregroundStyle(Color.Codive.grayscale3)
                }
            }
            .padding(.leading, 8)

            Spacer()

            if buttonStyle != .none {
                Button(action: action) {
                    Text(buttonTitle ?? "")
                        .font(.codive_body2_medium)
                        .foregroundStyle(buttonStyle == .primary ? .white : Color.Codive.main0)
                        .frame(minWidth: 76, minHeight: 32)
                        .background(buttonStyle == .primary ? Color.Codive.main0 : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(buttonStyle == .secondary ? Color.Codive.main0 : .clear, lineWidth: 1)
                        )
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    let dummyUser = SimpleUser(
        userId: 0,
        nickname: "닉네임",
        handle: "아이디",
        avatarURL: nil
    )

    VStack(spacing: 24) {
        CustomUserRow(user: dummyUser, buttonTitle: "팔로우", buttonStyle: .primary) { }
        CustomUserRow(user: dummyUser, buttonTitle: "팔로잉", buttonStyle: .secondary) { }
        CustomUserRow(user: dummyUser, buttonTitle: "차단 해제", buttonStyle: .secondary) { }
        CustomUserRow(user: dummyUser, buttonStyle: .none) { }
    }
}
