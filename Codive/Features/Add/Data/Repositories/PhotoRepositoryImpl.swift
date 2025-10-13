//
//  PhotoRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Photos
import UIKit

// MARK: - PhotoRepositoryImpl
final class PhotoRepositoryImpl: PhotoRepository {
    
    // MARK: - Properties
    private let dataSource: PhotoDataSource
    
    // MARK: - Initializer
    init(dataSource: PhotoDataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: - Methods
    func requestPhotoLibraryAuthorization() async -> PHAuthorizationStatus {
        return await dataSource.requestAuthorization()
    }
    
    func fetchAlbums() -> [PhotoAlbum] {
        let collections = dataSource.fetchAlbums()
        
        return collections.compactMap { collection in
            let assets = dataSource.fetchPhotos(from: collection)
            guard assets.count > 0 else { return nil }
            
            return PhotoAlbum(
                id: collection.localIdentifier,
                title: collection.localizedTitle ?? "알 수 없음",
                count: assets.count,
                collection: collection,
                thumbnail: assets.firstObject
            )
        }
    }
    
    func fetchPhotos(from album: PhotoAlbum) -> [PhotoAsset] {
        let fetchResult = dataSource.fetchPhotos(from: album.collection)
        var photos: [PhotoAsset] = []
        
        fetchResult.enumerateObjects { asset, _, _ in
            photos.append(
                PhotoAsset(
                    id: asset.localIdentifier,
                    asset: asset
                )
            )
        }
        
        return photos
    }
    
    func loadThumbnail(for asset: PHAsset, size: CGSize) async -> UIImage? {
        return await dataSource.loadImage(for: asset, size: size)
    }
}
