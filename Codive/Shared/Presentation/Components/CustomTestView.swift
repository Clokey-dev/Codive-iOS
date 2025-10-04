//
//  CustomTestView.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

struct CustomTestView: View {
    @State private var selectedStyles: Set<String> = []
    @State private var selectedSituations: Set<String> = []
    
    var body: some View {
        ScrollView {
            CustomAIRecommendationView(
                items: [
                    ClothingItem(
                        imageName: "sample_clothes1",
                        category: "상의",
                        subcategory: "블라우스",
                        season: "봄",
                        name: "핑크 블라우스",
                        brand: "",
                        purchaseUrl: ""
                    ),
                    ClothingItem(
                        imageName: "sample_clothes2",
                        category: "상의",
                        subcategory: "반팔티",
                        season: "봄, 여름, 가을",
                        name: "블랙 티셔츠",
                        brand: "",
                        purchaseUrl: ""
                    ),
                    ClothingItem(
                        imageName: "sample_clothes3",
                        category: "아우터",
                        subcategory: "점퍼/바람막이",
                        season: "봄, 가을",
                        name: "민트 셔츠 재킷",
                        brand: "",
                        purchaseUrl: ""
                    )
                ],
                selectedItemIndex: .constant(0),
                onCategoryTap: {
                    print("카테고리 선택")
                },
                onSeasonTap: {
                    print("계절 선택")
                }
            )
            .background(Color.white)
        }
    }
}

#Preview {
    CustomTestView()
}
