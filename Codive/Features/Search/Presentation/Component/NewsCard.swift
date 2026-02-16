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
    let subTitle: String
    let onTap: () -> Void

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
            VStack(alignment: .leading) {
                Text(title)
                    .font(Font.codive_title1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Text(subTitle)
                    .font(Font.codive_title1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .frame(width: 273, height: 300)
        .cornerRadius(16)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            NewsCard(
                imageUrl: "https://picsum.photos/273/300",
                title: "개강룩!",
                subTitle: "첫 인상 잡수 올리기"
            ) { print("첫 번째 카드 탭") }

            NewsCard(
                imageUrl: "https://picsum.photos/273/301",
                title: "가을 자켓",
                subTitle: "오늘의 코디"
            ) { print("두 번째 카드 탭") }
        }
        .padding(.horizontal, 20)
    }
}
