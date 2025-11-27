//
//  PostCard.swift
//  Codive
//
//  Created by 한금준 on 11/19/25.
//

import SwiftUI

struct PostCard: View {
    // MARK: - Properties
    let postImageUrl: String?
    let profileImageUrl: String?
    let nickname: String
    
    // MARK: - Constants (디자인 값)
    private let cardWidth: CGFloat = 162
    private let cardHeight: CGFloat = 216
    private let cornerRadius: CGFloat = 12
    private let profileImageSize: CGFloat = 28
    private let nicknameFont = Font.codive_body2_medium
    private let nicknameColor: Color = .white
    private let overlayLeft: CGFloat = 12
    private let overlayBottom: CGFloat = 10
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let urlString = postImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(Image(systemName: "photo").foregroundStyle(Color.gray))
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .clipped()
                .cornerRadius(cornerRadius)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(Image(systemName: "photo").foregroundStyle(Color.gray))
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()
                    .cornerRadius(cornerRadius)
            }
            HStack(spacing: 4) {
                if let urlString = profileImageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
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
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .frame(width: profileImageSize, height: profileImageSize)
                        .clipShape(Circle())
                }
                
                Text(nickname)
                    .font(nicknameFont)
                    .foregroundStyle(nicknameColor)
                    .lineLimit(1)
            }
            .padding(.leading, overlayLeft)
            .padding(.bottom, overlayBottom)
        }
        .frame(width: cardWidth, height: cardHeight)
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 20) {
        PostCard(
            postImageUrl: "https://picsum.photos/id/1018/162/216",
            profileImageUrl: "https://picsum.photos/id/237/28/28",
            nickname: "닉네임"
        )
        PostCard(
            postImageUrl: "https://picsum.photos/id/1019/162/216",
            profileImageUrl: nil,
            nickname: "긴닉네임테스트"
        )
        PostCard(
            postImageUrl: nil,
            profileImageUrl: "https://picsum.photos/id/1020/28/28",
            nickname: "유저123"
        )
    }
    .padding()
}
