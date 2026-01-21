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

    // content에서 해시태그 부분만 주황색으로 표시
    private var attributedContent: AttributedString {
        var attributed = AttributedString(content)

        // 해시태그 패턴 찾기 (#로 시작하는 단어)
        let pattern = "#[가-힣a-zA-Z0-9_]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            attributed.foregroundColor = Color.Codive.grayscale1
            return attributed
        }

        let nsString = content as NSString
        let matches = regex.matches(in: content, range: NSRange(location: 0, length: nsString.length))

        // 기본 색상 설정
        attributed.foregroundColor = Color.Codive.grayscale1

        // 각 해시태그 부분만 주황색으로
        for match in matches {
            if let range = Range(match.range, in: content) {
                let start = AttributedString.Index(range.lowerBound, within: attributed)
                let end = AttributedString.Index(range.upperBound, within: attributed)

                if let start = start, let end = end {
                    attributed[start..<end].foregroundColor = Color.Codive.point1
                }
            }
        }

        return attributed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Action Buttons
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    // 좋아요 아이콘 버튼
                    Button(action: onLikeTap) {
                        // TODO: - 하트 이미지 수정 필요
                        Image(isLiked ? "heart_on_main" : "heart_off_black")
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
            
            // Caption with colored hashtags
            if !content.isEmpty {
                Text(attributedContent)
                    .font(.codive_body2_regular)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
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
                        .padding(.horizontal, 9)
                        .padding(.vertical, 7)
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
