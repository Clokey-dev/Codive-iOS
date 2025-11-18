//
//  CustomProductCard.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import SwiftUI

struct CustomProductCard: View {
    
    // MARK: - Properties
    let imageName: String
    let label: String
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // 배경
                Color.Codive.grayscale6
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 상품 이미지
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 좌상단 라벨
                Text(label)
                    .font(.codive_body3_medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 3)
                    .background(Color.Codive.point2)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .padding(6)
            }
        }
        .aspectRatio(3/4, contentMode: .fit)
    }
}

// MARK: - Preview
#Preview {
    CustomProductCard(
        imageName: "sampleImage",
        label: "오늘의 코디"
    )
    .frame(width: 100)
    .padding(20)
}
