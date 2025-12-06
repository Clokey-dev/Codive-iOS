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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: onLikeTap) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(isLiked ? Color.red : Color.black)
                        Text("\(likeCount)")
                            .font(.codive_body2_regular)
                            .foregroundStyle(Color.black)
                    }
                }
                
                Button(action: onCommentTap) {
                    HStack(spacing: 4) {
                        Image("comment")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("\(commentCount)")
                            .font(.codive_body2_regular)
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
