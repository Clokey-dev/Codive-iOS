//
//  CustomProductCard.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import SwiftUI

struct CustomProductCard: View {
    let imageName: String
    let isTodayCloth: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 이미지
                Group {
                    if let url = URL(string: imageName), imageName.hasPrefix("http") {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                // 선택 오버레이
                if isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 100, height: 100)

                    // 갈색 원 + 체크마크
                    Circle()
                        .fill(Color(red: 0.45, green: 0.35, blue: 0.27))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )
                }

                // Today 뱃지
                if isTodayCloth {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Today")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.blue)
                                .clipShape(Capsule())
                                .padding(6)
                        }
                        Spacer()
                    }
                    .frame(width: 100, height: 100)
                }
            }
        }
    }
}
