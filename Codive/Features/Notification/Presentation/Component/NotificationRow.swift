//
//  NotificationRow.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

struct NotificationRow: View {
    // MARK: - Properties
    let profileImageUrl: String?
    let message: String
    
    // MARK: - Constants
    private let profileImageSize: CGFloat = 36
    private let horizontalPadding: CGFloat = 20
    private let verticalPadding: CGFloat = 10
    private let messageFont = Font.codive_body2_regular
    private let messageColor = Color.Codive.grayscale1
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: profileImageUrl ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundStyle(Color.gray.opacity(0.3))
                } else {
                    ProgressView()
                }
            }
            .frame(width: profileImageSize, height: profileImageSize)
            .clipShape(Circle())

            Text(message)
                .font(messageFont)
                .foregroundStyle(messageColor)
            
            Spacer()
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 10) {
        NotificationRow(
            profileImageUrl: "https://picsum.photos/id/237/200/200",
            message: "홍길동님이 회원님의 옷장을 팔로우하기 시작했습니다."
        )
        NotificationRow(
            profileImageUrl: nil,
            message: "김철수님이 새로운 게시물을 업로드했습니다."
        )
        NotificationRow(
            profileImageUrl: "invalid_url",
            message: "이영희님이 회원님의 게시물에 좋아요를 눌렀습니다."
        )
    }
}
