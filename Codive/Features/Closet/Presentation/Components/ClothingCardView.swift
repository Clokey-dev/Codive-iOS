//
//  ClothingCardView.swift
//  Codive
//
//  Created by 황상환 on 12/13/25.
//

import SwiftUI

struct ClothingCardView: View {

    let brand: String
    let name: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 이미지 영역
            Rectangle()
                .fill(Color.Codive.grayscale4)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundStyle(Color.Codive.grayscale3)
                )
                .frame(height: 124)
            
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
