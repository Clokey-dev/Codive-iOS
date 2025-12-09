//
//  RemoteTaggableImageView.swift
//  Codive
//
//  Created by 황상환 on 12/7/25.
//

import SwiftUI

/// URL에서 이미지를 로드하여 TaggableImageView로 표시하는 뷰 (읽기 전용)
struct RemoteTaggableImageView: View {

    // MARK: - Properties
    let imageUrl: String
    @Binding var tags: [ClothTag]
    let selectedTagId: UUID?
    let onTagTap: ((UUID) -> Void)?

    @State private var loadedImage: UIImage?
    @State private var isLoading: Bool = true
    @State private var loadFailed: Bool = false

    // MARK: - Body
    var body: some View {
        Group {
            if let image = loadedImage {
                // 이미지 로드 완료
                TaggableImageView(
                    image: image,
                    tags: $tags,
                    selectedTagId: selectedTagId,
                    onTagTap: onTagTap,
                    isDraggable: false,
                    isReadOnly: true,
                    contentMode: .fill
                )
            } else if loadFailed {
                // 로드 실패
                placeholderView
            } else {
                // 로딩 중
                ZStack {
                    Color.gray.opacity(0.1)
                    ProgressView()
                }
            }
        }
        .task(id: imageUrl) {
            await loadImage()
        }
    }

    // MARK: - Placeholder
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.1)
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(Color.gray)
        }
    }

    // MARK: - Image Loading
    private func loadImage() async {
        guard let url = URL(string: imageUrl) else {
            loadFailed = true
            isLoading = false
            return
        }

        do {
            // TODO: Kingfisher 설치 후 KFImage로 교체 예정
            let (data, _) = try await URLSession.shared.data(from: url)

            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.loadedImage = image
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.loadFailed = true
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.loadFailed = true
                self.isLoading = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    RemoteTaggableImageView(
        imageUrl: "https://via.placeholder.com/300x400",
        tags: .constant([
            ClothTag(id: UUID(), clothId: 1, brand: "Nike", name: "Shirt", locationX: 0.5, locationY: 0.3)
        ]),
        selectedTagId: nil
    ) { tagId in
        print("Tag tapped: \(tagId)")
    }
    .aspectRatio(3/4, contentMode: .fit)
}
