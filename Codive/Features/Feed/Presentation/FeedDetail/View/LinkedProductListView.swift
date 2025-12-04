//
//  LinkedProductListView.swift
//  Codive
//
//  Created by 황상환 on 12/3/25.
//

import SwiftUI

struct LinkedProductListView: View {
    
    // MARK: - Properties
    let tags: [ClothTag]
    @Binding var selectedTagId: UUID?
    
    // MARK: - Body
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags) { tag in
                    Button(action: {
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
            .padding(.top, 11)
        }
    }
}

// MARK: - Item View
private struct ProductThumbnailItem: View {
    let isSelected: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.1))
            .frame(width: 60, height: 60)
            .overlay(
                Image(systemName: "tshirt")
                    .foregroundStyle(Color.gray)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.black : Color.clear, lineWidth: 1)
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
