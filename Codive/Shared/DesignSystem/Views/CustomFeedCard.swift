//
//  CustomFeedCard.swift
//  Codive
//
//  Created by 황상환 on 12/1/25.
//

import SwiftUI

struct CustomFeedCard: View {
    // MARK: - Properties
    let imageUrl: String
    let profileImageUrl: String
    let nickname: String
    
    @Binding var isLiked: Bool
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // 메인 배경 이미지
            Rectangle()
                .fill(Color.gray)
                .overlay(
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                )
                .overlay(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.2)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )

            // 좋아요 버튼 (우측 상단)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isLiked.toggle()
                    }, label: {
                        Image(isLiked ? "heart_on" : "heart_off")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                    })
                }
                Spacer()
            }
            .padding(15)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 프로필 정보
            HStack(spacing: 8) {
                // 프로필 이미지
                AsyncImage(url: URL(string: profileImageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())

                // 닉네임
                Text(nickname)
                    .font(.codive_body2_medium)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.leading, 15)
            .padding(.bottom, 15)
        }
        // 카드 전체 스타일
        .aspectRatio(3/4, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        CustomFeedCard(
            imageUrl: "sample_feed_image",
            profileImageUrl: "sample_profile",
            nickname: "닉네임",
            isLiked: .constant(true)
        )
        .frame(width: 160)
    }
}
