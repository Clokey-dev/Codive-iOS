//
//  PhotoRepository.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Photos
import UIKit

// MARK: - PhotoRepository Protocol
protocol PhotoRepository {
    func requestPhotoLibraryAuthorization() async -> PHAuthorizationStatus
    func fetchAlbums() -> [PhotoAlbum]
    func fetchPhotos(from album: PhotoAlbum) -> [PhotoAsset]
    func loadThumbnail(for asset: PHAsset, size: CGSize) async -> UIImage?
}
