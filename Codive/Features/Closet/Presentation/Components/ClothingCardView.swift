//
//  ClothingCardView.swift
//  Codive
//
//  Created by 황상환 on 12/13/25.
//

import SwiftUI

struct ClothingCardView: View {

    let imageUrl: String?
    let brand: String
    let name: String

    init(imageUrl: String? = nil, brand: String, name: String) {
        self.imageUrl = imageUrl
        self.brand = brand
        self.name = name
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 이미지 영역
            if let imageUrl = imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.Codive.grayscale5)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(let error):
                        let _ = print("❌ [ClothingCard] 이미지 로드 실패: \(error)")
                        Rectangle()
                            .fill(Color.Codive.grayscale4)
                            .overlay(
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(Color.red)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 124)
                .clipped()
            } else {
                Rectangle()
                    .fill(Color.Codive.grayscale4)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(Color.Codive.grayscale3)
                    )
                    .frame(height: 124)
            }
            
            // 정보 영역
            VStack(alignment: .leading, spacing: 4) {
                Text(brand)
                    .font(.codive_body3_regular)
                    .foregroundStyle(Color.Codive.grayscale3)
                
                Text(name)
                    .font(.codive_body2_medium)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .lineLimit(1)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .frame(width: 124)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.Codive.grayscale6, lineWidth: 1)
        )
    }
}

#Preview {
    ClothingCardView(brand: "나이키", name: "Cable knit cardigan")
        .padding()
}
