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
    @Binding var selectedProducts: Set<UUID>
    let products: [ProductItem]
    let onProductTap: (ProductItem) -> Void

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
                    ForEach(products.sorted { $0.isTodayCloth && !$1.isTodayCloth }) { product in
                        CustomProductCard(
                            imageName: product.imageName,
                            isTodayCloth: product.isTodayCloth,
                            isSelected: selectedProducts.contains(product.id),
                            onTap: {
                                onProductTap(product)
                            }
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
    let isTodayCloth: Bool
    let brand: String?
    let name: String?
}

// MARK: - Preview
#Preview {
    CustomProductBottomSheet(
        searchText: .constant(""),
        selectedCategory: .constant("전체"),
        selectedProducts: .constant([]),
        products: [
            ProductItem(imageName: "sample1", isTodayCloth: true, brand: "Nike", name: "에어포스 1"),
            ProductItem(imageName: "sample2", isTodayCloth: false, brand: "Adidas", name: "후디")
        ],
        onProductTap: { _ in }
    )
}
