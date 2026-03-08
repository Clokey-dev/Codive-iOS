//
//  FeedImageSlider.swift
//  Codive
//
//  Created by 황상환 on 12/1/25.
//

import SwiftUI

struct FeedImageSlider: View {

    // MARK: - Properties
    let imageUrls: [String]
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

            if !imageUrls.isEmpty {
                GeometryReader { geometry in
                    TabView(selection: $currentIndex) {
                        ForEach(imageUrls.indices, id: \.self) { index in
                            let currentTags = showTags && index < tags.count ? tags[index] : []

                            RemoteTaggableImageView(
                                imageUrl: imageUrls[index],
                                tags: .constant(currentTags),
                                selectedTagId: selectedTagId,
                                onTagTap: onTagTap
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }

            // 페이지 인디케이터 (우측 상단)
            if imageUrls.count > 1 {
                VStack {
                    HStack {
                        Spacer()
                        Text("\(currentIndex + 1)/\(imageUrls.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
                .padding(.trailing, 20)
                .padding(.top, 20)
            }

            if currentIndex < tags.count, !tags[currentIndex].isEmpty {
                Button(action: {
                    withAnimation {
                        onTagButtonTap()
                    }
                }, label: {
                    ZStack {
                        Image("tag")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    }
                })
                .padding(.leading, 20)
                .padding(.bottom, 20)
            }
        }
        .aspectRatio(3/4, contentMode: .fill)
        .clipped()
    }
}

// MARK: - Preview
#Preview {
    let onTagButtonTapClosure = { print("Tag button tapped") }
    let onTagTapClosure: (UUID) -> Void = { tagId in print("Tag tapped: \(tagId)") }

    FeedImageSlider(
        imageUrls: [
            "https://via.placeholder.com/300x400",
            "https://via.placeholder.com/300x400/0000FF"
        ],
        tags: [
            [ClothTag(id: UUID(), clothId: 1, brand: "Typeservice", name: "Layered Henry Neck", imageUrl: nil, locationX: 0.3, locationY: 0.4)],
            []
        ],
        currentIndex: .constant(0),
        showTags: true,
        selectedTagId: nil,
        onTagButtonTap: onTagButtonTapClosure,
        onTagTap: onTagTapClosure
    )
}
