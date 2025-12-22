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
    var action: () -> Void = {}   

    var body: some View {
        Button(action: { action() }, label: {
            VStack(alignment: .leading, spacing: 6) {
                // 상품 이미지
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()

                // 브랜드
                Text(brand)
                    .font(.codive_body3_regular)
                    .foregroundStyle(Color("Grayscale4"))
                    .padding(.horizontal, 8)

                // 상품명
                Text(title)
                    .font(.codive_body2_medium)
                    .foregroundStyle(Color("Grayscale2"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 8)

            }
        })
        .buttonStyle(.plain)
    }
}

struct ClothGridView: View {
    let items = Array(repeating: 0, count: 9)
    let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(items.indices, id: \.self) { idx in
                    CustomClothCard(
                        imageName: "sampleCloth",
                        brand: "나이키",
                        title: "Cable knit cardigan navy blue"
                    ) {
                        print("탭된 아이템: \(idx)")
                    }
                }
            }
            .padding(.top, 12)
        }
    }
}

#Preview {
    ClothGridView()
}
