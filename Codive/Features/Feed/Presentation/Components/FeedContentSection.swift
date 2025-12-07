//
//  FeedContentSection.swift
//  Codive
//
//  Created by 황상환 on 12/3/25.
//

import SwiftUI

struct FeedContentSection: View {
    let likeCount: Int
    let commentCount: Int
    let isLiked: Bool
    let content: String
    let hashtags: [String]
    let date: String
    let styles: [String]
    let onLikeTap: () -> Void
    let onCommentTap: () -> Void
    let onLikesCountTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Action Buttons
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    // 좋아요 아이콘 버튼
                    Button(action: onLikeTap) {
                        // TODO: - 하트 이미지 수정 필요
                        Image(isLiked ? "heart_on" : "heart_off_black")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    
                    // 좋아요 숫자 버튼
                    Button(action: onLikesCountTap) {
                        Text("\(likeCount)")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.black)
                            .monospacedDigit()
                    }
                    .disabled(likeCount == 0)
                }
                
                Button(action: onCommentTap) {
                    HStack(spacing: 4) {
                        Image("comment")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("\(commentCount)")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.black)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Caption
            Text(content)
                .font(.codive_body2_regular)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            
            // Hashtags
            if !hashtags.isEmpty {
                Text(hashtags.map { "#\($0)" }.joined(separator: " "))
                    .font(.codive_body2_regular)
                    .foregroundStyle(Color.Codive.point1)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }
            
            // Date
            Text(date)
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale3)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            
            // 밑줄
            Rectangle()
                .fill(Color.Codive.grayscale6)
                .frame(height: 1)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // 고정 태그들
            HStack(spacing: 8) {
                ForEach(styles, id: \.self) { style in
                    Text(style)
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.Codive.grayscale4, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}
