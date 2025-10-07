//
//  CustomClothCard.swift
//  Codive
//
//  Created by 한태빈 on 10/6/25.
//

import SwiftUI

struct CustomClothCard: View {
    let imageName: String
    let brand: String
    let title: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: 6) {
                // 상품 이미지
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit) // 정사각형 썸네일
                    .clipped()

                // 브랜드
                Text(brand)
                    .font(.codive_body3_regular)
                    .foregroundColor(Color("Grayscale4"))

                // 상품명
                Text(title)
                    .font(.codive_body2_medium)
                    .foregroundColor(Color("Grayscale2"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .buttonStyle(.plain)
    }
}

//예시로 보여주기 위해 대충 만든 View
struct ClothGridView: View {
    let items = Array(repeating: 0, count: 9)

    let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(items.indices, id: \.self) { _ in
                    CustomClothCard(
                        imageName: "sampleCloth",
                        brand: "나이키",
                        title: "Cable knit cardigan navy blue"
                    )
                }
            }
            .padding(.top, 12)
        }
    }
}

#Preview {
    ClothGridView()
}
