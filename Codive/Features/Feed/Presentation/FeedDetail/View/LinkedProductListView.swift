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
            HStack(spacing: 10) {
                ForEach(tags) { tag in
                    Button(action: {
                        if selectedTagId == tag.id {
                            selectedTagId = nil
                        } else {
                            selectedTagId = tag.id
                        }
                    }, label: {
                        ProductThumbnailItem(
                            tag: tag,
                            isSelected: selectedTagId == tag.id
                        )
                    })
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 11)
        }
    }
}

// MARK: - Item View
private struct ProductThumbnailItem: View {
    let tag: ClothTag
    let isSelected: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.1))
            .frame(width: 60, height: 60)
            .overlay(
                Group {
                    if let imageUrl = tag.imageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Image(systemName: "tshirt")
                                    .foregroundStyle(Color.gray)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "tshirt")
                            .foregroundStyle(Color.gray)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.black : Color.clear, lineWidth: 2)
            )
            .padding(.bottom, 2)
    }
}

// MARK: - Preview
#Preview {
    LinkedProductListView(
        tags: [
            ClothTag(id: UUID(), clothId: 1, brand: "Nike", name: "Shirt", imageUrl: nil, locationX: 0, locationY: 0),
            ClothTag(id: UUID(), clothId: 2, brand: "Adidas", name: "Pants", imageUrl: nil, locationX: 0, locationY: 0)
        ],
        selectedTagId: .constant(nil)
    )
}
