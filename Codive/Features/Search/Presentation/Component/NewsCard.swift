//
//  NewsCard.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

struct NewsCard: View {
    let imageUrl: String
    let title: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 배경 이미지
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 273, height: 300)
            .clipped()
            
            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .leading,
                endPoint: .bottom
            )
            
            // 텍스트
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
        .frame(width: 273, height: 300)
        .cornerRadius(16)
    }
}

// MARK: - Preview
#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            NewsCard(
                imageUrl: "https://picsum.photos/273/300",
                title: "개강룩!\n첫 인상 잡수 올리기"
            )
            
            NewsCard(
                imageUrl: "https://picsum.photos/273/301",
                title: "가을 자켓\n오늘의 코디"
            )
        }
        .padding(.horizontal, 20)
    }
}
