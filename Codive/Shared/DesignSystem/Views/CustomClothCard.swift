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
            // 카드 전체를 3:4 비율로 고정
            VStack(alignment: .leading, spacing: 0) {
                // 1. 상품 이미지 영역 (회색 배경)
                ZStack {
                    Color.Codive.grayscale7 // 또는 Color.gray
                    
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .clipped()
                // 이미지가 카드 높이의 약 75~80%를 차지하도록 유도 (비율에 따라 조정 가능)
                .frame(maxWidth: .infinity)
                .layoutPriority(1)

                // 2. 텍스트 영역
                VStack(alignment: .leading, spacing: 2) {
                    Text(brand)
                        .font(.codive_body4_regular) // 크기에 맞춰 조금 더 작은 폰트 권장
                        .foregroundStyle(Color.Codive.grayscale4)
                        .lineLimit(1)

                    Text(title)
                        .font(.codive_body3_medium)
                        .foregroundStyle(Color.Codive.grayscale2)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
            }
            .aspectRatio(3/4, contentMode: .fit) // 카드당 3:4 비율 적용
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
