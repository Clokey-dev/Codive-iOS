//
//  FetchPhotosUseCase.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Photos
import UIKit

// MARK: - FetchPhotosUseCase
final class FetchPhotosUseCase {
    
    // MARK: - Properties
    private let repository: PhotoRepository
    
    // MARK: - Initializer
    init(repository: PhotoRepository) {
        self.repository = repository
    }
    
    // MARK: - Methods
    func requestAuthorization() async -> PHAuthorizationStatus {
        return await repository.requestPhotoLibraryAuthorization()
    }
    
    func fetchAlbums() -> [PhotoAlbum] {
        return repository.fetchAlbums()
    }
    
    func fetchPhotos(from album: PhotoAlbum) -> [PhotoAsset] {
        return repository.fetchPhotos(from: album)
    }
    
    func loadThumbnail(for asset: PHAsset, size: CGSize) async -> UIImage? {
        return await repository.loadThumbnail(for: asset, size: size)
    }
}
