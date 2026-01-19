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
            ZStack(alignment: .topTrailing) {
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
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
                
                // Today 뱃지
                if isTodayCloth {
                    Text("Today")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .padding(6)
                }
                
                // 선택 체크마크
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .background(Color.white.clipShape(Circle()))
                        .padding(6)
                }
            }
        }
    }
}
