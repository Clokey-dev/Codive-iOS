//
//  LinkedProductListView.swift
//  Codive
//
//  Created by 황상환 on 12/3/25.
//

import SwiftUI

struct LinkedProductListView: View {
    
    // MARK: - Properties
    let tags: [ClothTag] // 현재 보여지는 이미지에 포함된 태그들
    @Binding var selectedTagId: UUID? // 선택된 태그 ID (없으면 nil)
    
    // MARK: - Body
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(tags) { tag in
                    Button(action: {
                        // 이미 선택된 걸 다시 누르면 해제 or 유지 (기획에 따라 결정)
                        if selectedTagId == tag.id {
                            selectedTagId = nil
                        } else {
                            selectedTagId = tag.id
                        }
                    }) {
                        ProductThumbnailItem(
                            isSelected: selectedTagId == tag.id
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Item View
private struct ProductThumbnailItem: View {
    let isSelected: Bool
    // 실제로는 imageURL 등을 받아야 함
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.1)) // Placeholder color
            .frame(width: 60, height: 60)
            .overlay(
                // 상품 이미지 (임시 아이콘)
                Image(systemName: "tshirt")
                    .foregroundStyle(Color.gray)
            )
            .overlay(
                // 선택 시 검은 테두리
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.black : Color.clear, lineWidth: 2)
            )
    }
}

// MARK: - Preview
#Preview {
    LinkedProductListView(
        tags: [
            ClothTag(id: UUID(), clothId: UUID(), brand: "Nike", name: "Shirt", locationX: 0, locationY: 0),
            ClothTag(id: UUID(), clothId: UUID(), brand: "Adidas", name: "Pants", locationX: 0, locationY: 0)
        ],
        selectedTagId: .constant(nil)
    )
}
