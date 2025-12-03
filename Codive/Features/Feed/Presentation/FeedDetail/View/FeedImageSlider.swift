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
    @State private var showTags: Bool = true // 기본값을 true로 변경하여 태그가 보이도록 함
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // 배경색을 먼저 지정합니다.
            Color.gray
            
            // 이미지가 있을 경우에만 TabView를 표시합니다.
            if !images.isEmpty {
                TabView(selection: $currentIndex) {
                    ForEach(images.indices, id: \.self) { index in
                        // 현재 페이지의 태그 가져오기 (showTags가 true일 때만)
                        let currentTags = showTags && index < tags.count ? tags[index] : []
                        
                        TaggableImageView(
                            image: images[index],
                            tags: .constant(currentTags),
                            onTagTap: { tagId in
                                print("태그 탭: \(tagId)")
                            },
                            isDraggable: false,
                            isReadOnly: true
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            // Tag Toggle Button은 항상 ZStack 최상단에 위치합니다.
            Button(action: {
                withAnimation {
                    showTags.toggle()
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
        currentIndex: .constant(0)
    )
}
