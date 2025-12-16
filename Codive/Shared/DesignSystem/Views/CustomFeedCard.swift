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
                    Image(imageUrl)
                        .resizable()
                        .scaledToFill()
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
            HStack {
                // 프로필 이미지
                Image(profileImageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                    )
                
                // 닉네임
                Text(nickname)
                    .font(.codive_body2_medium)
                    .foregroundStyle(.white)
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
