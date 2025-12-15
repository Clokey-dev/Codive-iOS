//
//  TaggableImageView.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import SwiftUI

struct TaggableImageView: View {
    
    // MARK: - Properties

    let image: UIImage
    @Binding var tags: [ClothTag]
    
    // Interaction Properties
    let selectedTagId: UUID?
    let onTagRemove: ((UUID) -> Void)?
    let onTagTap: ((UUID) -> Void)?
    let isDraggable: Bool
    let isReadOnly: Bool
    
    @State private var imageSize: CGSize = .zero
    
    // MARK: - Initializer
    init(
        image: UIImage,
        tags: Binding<[ClothTag]>,
        selectedTagId: UUID?,
        onTagRemove: ((UUID) -> Void)? = nil,
        onTagTap: ((UUID) -> Void)? = nil,
        isDraggable: Bool = true,
        isReadOnly: Bool = false
    ) {
        self.image = image
        self._tags = tags
        self.selectedTagId = selectedTagId
        self.onTagRemove = onTagRemove
        self.onTagTap = onTagTap
        self.isDraggable = isDraggable
        self.isReadOnly = isReadOnly
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
                                .onAppear { imageSize = proxy.size }
                                .onChange(of: proxy.size) { newSize in imageSize = newSize }
                        }
                    )
                
                // 태그들
                ForEach(tags) { tag in
                    // 읽기 모드에 따라 태그 뷰 분기
                    if isReadOnly {
                        // 상세 화면용: 위치 고정, Navigable 스타일
                        CustomTagView(
                            type: .navigable(
                                title: tag.brand.isEmpty ? "Brand" : tag.brand,
                                content: tag.name.isEmpty ? "Product Name" : tag.name
                            ) { 
                                onTagTap?(tag.id)
                            }
                        )
                        .position(
                            x: tag.locationX * imageSize.width,
                            y: tag.locationY * imageSize.height
                        )
                        // 선택된 태그 하이라이팅
                        .opacity(selectedTagId == nil || selectedTagId == tag.id ? 1.0 : 0.5)
                    } else {
                        // 편집 화면용: 드래그 가능, Closable 스타일 (기존 로직)
                        DraggableTag(
                            tag: tag,
                            imageSize: imageSize,
                            isDraggable: isDraggable,
                            onDrag: { newX, newY in
                                updateTagPosition(tag.id, x: newX, y: newY)
                            },
                            onRemove: {
                                onTagRemove?(tag.id)
                            }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .coordinateSpace(name: "imageZStack")
            .clipped()
        }
    }
    
    private func updateTagPosition(_ tagId: UUID, x: CGFloat, y: CGFloat) {
        if let index = tags.firstIndex(where: { $0.id == tagId }) {
            tags[index].locationX = x
            tags[index].locationY = y
        }
    }
}

// DraggableTag는 기존 코드 유지 (편집 화면용)
private struct DraggableTag: View {
    let tag: ClothTag
    let imageSize: CGSize
    let isDraggable: Bool
    let onDrag: (CGFloat, CGFloat) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        CustomTagView(
            type: .closable(
                title: tag.brand.isEmpty ? "Brand" : tag.brand,
                content: tag.name.isEmpty ? "Product Name" : tag.name,
                onClose: onRemove
            )
        )
        .position(
            x: tag.locationX * imageSize.width,
            y: tag.locationY * imageSize.height
        )
        .gesture(
            isDraggable ? DragGesture(coordinateSpace: .named("imageZStack"))
                .onChanged { value in
                    let newX = value.location.x / imageSize.width
                    let newY = value.location.y / imageSize.height
                    onDrag(newX, newY)
                }
            : nil
        )
    }
}
