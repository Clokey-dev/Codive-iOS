//
//  PhotoAlbum.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Photos
import UIKit

// MARK: - PhotoAlbum Entity
struct PhotoAlbum {
    let id: String
    let title: String
    let count: Int
    let collection: PHAssetCollection
    let thumbnail: PHAsset?
}

// MARK: - PhotoAsset Entity
struct PhotoAsset: Identifiable {
    let id: String
    let asset: PHAsset
    var isSelected: Bool = false
    var selectionOrder: Int?
}

// MARK: - SelectedPhoto Entity
struct SelectedPhoto: Identifiable, Equatable, Hashable {
    let id: String
    private(set) var originalImagePath: URL?
    var croppedImage: UIImage
    var order: Int
    var clothTags: [ClothTag] = []
    var imageUrl: String? // 수정 모드에서 기존 이미지 URL 저장
    var aiImageUrl: String? // AI 누끼 이미지 URL

    /// 원본 이미지를 tmp 디스크에 저장하고 경로만 보관 (메모리 절약)
    mutating func saveOriginalToDisk(_ image: UIImage) {
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("original_\(id).jpg")
        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: path)
            originalImagePath = path
        }
    }

    /// 재크롭 시에만 디스크에서 원본 이미지 로드
    func loadOriginalImage() -> UIImage? {
        guard let path = originalImagePath,
              let data = try? Data(contentsOf: path) else { return nil }
        return UIImage(data: data)
    }

    /// tmp 파일 정리
    func cleanupOriginal() {
        guard let path = originalImagePath else { return }
        try? FileManager.default.removeItem(at: path)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(order)
    }

    static func == (lhs: SelectedPhoto, rhs: SelectedPhoto) -> Bool {
        lhs.id == rhs.id && lhs.order == rhs.order
    }
}
