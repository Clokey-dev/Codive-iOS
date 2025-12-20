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
    
    // 편집 모드 관련 프로퍼티 추가
    var isEditMode: Bool = false
    var isSelected: Bool = false
    
    var action: () -> Void = {}

    var body: some View {
        Button(action: { action() }, label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) { // 선택 원 배치를 위해 topTrailing 설정
                    // 1. 상품 이미지
                    ZStack {
                        Color.Codive.grayscale7
                        
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        
                        // 선택 시 회색 오버레이 (삭제 선택.png 참고)
                        if isEditMode && isSelected {
                            Color.black.opacity(0.1)
                        }
                    }
                    .clipped()
                    
                    // 2. 편집 모드일 때 나타나는 선택 원
                    if isEditMode {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(isSelected ? Color.Codive.point1 : Color.white)
                            .background(isSelected ? Color.white : Color.black.opacity(0.2))
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .layoutPriority(1)

                // 3. 텍스트 영역
                VStack(alignment: .leading, spacing: 2) {
                    Text(brand)
                        .font(.codive_body4_regular)
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
            .aspectRatio(3/4, contentMode: .fit)
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
