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
    let originalImage: UIImage
    var croppedImage: UIImage
    var order: Int
    var clothTags: [ClothTag] = []
    var imageUrl: String? // 수정 모드에서 기존 이미지 URL 저장
    var aiImageUrl: String? // AI 누끼 이미지 URL

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(order)
    }

    static func == (lhs: SelectedPhoto, rhs: SelectedPhoto) -> Bool {
        lhs.id == rhs.id && lhs.order == rhs.order
    }
}
