//
//  TaggableImageView.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import SwiftUI

// MARK: - TaggableImageView
struct TaggableImageView: View {
    
    // MARK: - Properties
    let image: UIImage
    @Binding var tags: [ClothTag]
    let onTagRemove: (UUID) -> Void
    let isDraggable: Bool
    
    @State private var imageSize: CGSize = .zero
    
    // MARK: - Initializer
    init(
        image: UIImage,
        tags: Binding<[ClothTag]>,
        onTagRemove: @escaping (UUID) -> Void,
        isDraggable: Bool = true
    ) {
        self.image = image
        self._tags = tags
        self.onTagRemove = onTagRemove
        self.isDraggable = isDraggable
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { _ in
            ZStack {
                // 이미지
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    imageSize = proxy.size
                                }
                                .onChange(of: proxy.size) { newSize in
                                    imageSize = newSize
                                }
                        }
                    )
                
                // 태그들
                ForEach(tags) { tag in
                    DraggableTag(
                        tag: tag,
                        imageSize: imageSize,
                        isDraggable: isDraggable,
                        onDrag: { newX, newY in
                            updateTagPosition(tag.id, x: newX, y: newY)
                        },
                        onRemove: {
                            onTagRemove(tag.id)
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: - Private Methods
    private func updateTagPosition(_ tagId: UUID, x: CGFloat, y: CGFloat) {
        if let index = tags.firstIndex(where: { $0.id == tagId }) {
            tags[index].locationX = x
            tags[index].locationY = y
        }
    }
}

// MARK: - DraggableTag
private struct DraggableTag: View {
    let tag: ClothTag
    let imageSize: CGSize
    let isDraggable: Bool
    let onDrag: (CGFloat, CGFloat) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        CustomTagView(
            type: .closable(
                title: tag.brand.isEmpty ? "브랜드" : tag.brand,
                content: tag.name.isEmpty ? "상품명" : tag.name,
                onClose: onRemove
            )
        )
        .position(
            x: tag.locationX * imageSize.width,
            y: tag.locationY * imageSize.height
        )
        .gesture(
            isDraggable ? DragGesture()
                .onChanged { value in
                    let newX = value.location.x / imageSize.width
                    let newY = value.location.y / imageSize.height
                    onDrag(newX, newY)
                }
            : nil
        )
    }
}

// MARK: - Preview
#Preview {
    TaggableImageView(
        image: UIImage(systemName: "photo")!,
        tags: .constant([
            ClothTag(id: UUID(), clothId: UUID(), brand: "Nike", name: "에어포스 1", locationX: 0.3, locationY: 0.4),
            ClothTag(id: UUID(), clothId: UUID(), brand: "Adidas", name: "후디", locationX: 0.6, locationY: 0.7)
        ]),
        onTagRemove: { _ in },
        isDraggable: true
    )
}
