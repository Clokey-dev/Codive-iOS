//
//  FeedImageSlider.swift
//  Codive
//
//  Created by 황상환 on 12/1/25.
//

import SwiftUI

struct FeedImageSlider: View {
    
    // MARK: - Properties
    let images: [UIImage]
    let tags: [[ClothTag]]
    
    @Binding var currentIndex: Int
    
    let showTags: Bool
    let selectedTagId: UUID?
    let onTagButtonTap: () -> Void
    let onTagTap: (UUID) -> Void

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            Color.gray
            
            if !images.isEmpty {
                TabView(selection: $currentIndex) {
                    ForEach(images.indices, id: \.self) { index in
                        let currentTags = showTags && index < tags.count ? tags[index] : []
                        
                        TaggableImageView(
                            image: images[index],
                            tags: .constant(currentTags),
                            selectedTagId: selectedTagId,
                            onTagTap: onTagTap,
                            isDraggable: false,
                            isReadOnly: true
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            Button(action: {
                withAnimation {
                    onTagButtonTap()
                }
            }) {
                ZStack {
                    Image("tag")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
        }
        .aspectRatio(3/4, contentMode: .fit)
    }
}

// MARK: - Preview
#Preview {
    FeedImageSlider(
        images: [UIImage(systemName: "photo")!, UIImage(systemName: "photo.fill")!],
        tags: [
            [ClothTag(id: UUID(), clothId: UUID(), brand: "Typeservice", name: "Layered Henry Neck", locationX: 0.3, locationY: 0.4)],
            []
        ],
        currentIndex: .constant(0),
        showTags: true,
        selectedTagId: nil,
        onTagButtonTap: { print("Tag button tapped") },
        onTagTap: { tagId in print("Tag tapped: \(tagId)") }
    )
}
