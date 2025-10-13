//
//  PhotoAlbum.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Photos

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
