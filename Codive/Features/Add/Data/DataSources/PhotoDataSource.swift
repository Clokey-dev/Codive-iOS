//
//  PhotoDataSource.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Photos
import UIKit

// MARK: - PhotoDataSource
final class PhotoDataSource {
    
    // MARK: - Properties
    private let imageManager = PHCachingImageManager()
    
    // MARK: - Authorization
    func requestAuthorization() async -> PHAuthorizationStatus {
        return await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }
    
    // MARK: - Fetch Albums
    func fetchAlbums() -> [PHAssetCollection] {
        var albums: [PHAssetCollection] = []
        
        // 최근 항목 (스마트 앨범)
        let recentAlbum = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumUserLibrary,
            options: nil
        )
        recentAlbum.enumerateObjects { collection, _, _ in
            albums.append(collection)
        }
        
        // 사용자 앨범
        let userAlbums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: nil
        )
        userAlbums.enumerateObjects { collection, _, _ in
            albums.append(collection)
        }
        
        // 스마트 앨범 (셀피, 즐겨찾기 등)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: nil
        )
        smartAlbums.enumerateObjects { collection, _, _ in
            // 최근 항목 중복 제거
            if collection.assetCollectionSubtype != .smartAlbumUserLibrary {
                albums.append(collection)
            }
        }
        
        return albums
    }
    
    // MARK: - Fetch Photos
    func fetchPhotos(from collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        return PHAsset.fetchAssets(in: collection, options: options)
    }
    
    // MARK: - Load Image
    func loadImage(for asset: PHAsset, size: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            imageManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
