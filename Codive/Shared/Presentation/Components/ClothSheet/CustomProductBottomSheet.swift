//
//  CustomProductBottomSheet.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import SwiftUI

struct CustomProductBottomSheet: View {
    
    // MARK: - Properties
    @Binding var searchText: String
    @Binding var selectedCategory: String
    let products: [ProductItem]

    private let categories = ["전체", "상의", "바지", "스커트", "아우터", "신발", "가방", "패션소품"]
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            // 검색창
            CustomSearchBar(
                text: $searchText,
                type: .normal
            )
            .padding(.horizontal, 20)
            
            // 카테고리 태그
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        CustomCategoryTag(
                            title: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // 상품 그리드
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(products) { product in
                        CustomProductCard(
                            imageName: product.imageName,
                            label: product.label
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 16)
    }
}

// MARK: - Product Item Model
struct ProductItem: Identifiable {
    let id = UUID()
    let imageName: String
    let label: String
}

// MARK: - Preview
#Preview {
    CustomProductBottomSheet(
        searchText: .constant(""),
        selectedCategory: .constant("전체"),
        products: [
            ProductItem(imageName: "sample1", label: "오늘의 코디"),
            ProductItem(imageName: "sample2", label: "오늘의 코디"),
            ProductItem(imageName: "sample3", label: "오늘의 코디")
        ]
    )
}
