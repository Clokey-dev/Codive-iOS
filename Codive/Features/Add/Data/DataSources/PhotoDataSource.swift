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
    
    // MARK: - Fetch Collections
    
    /// 최근 항목 스마트 앨범 가져오기
    func fetchRecentCollection() -> PHAssetCollection? {
        let collections = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumUserLibrary,
            options: nil
        )
        return collections.firstObject
    }
    
    /// 사용자가 만든 앨범들 가져오기
    func fetchUserCollections() -> [PHAssetCollection] {
        var collections: [PHAssetCollection] = []
        
        let fetchResult = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: nil
        )
        
        fetchResult.enumerateObjects { collection, _, _ in
            collections.append(collection)
        }
        
        return collections
    }
    
    /// 스마트 앨범들 가져오기 (최근 항목 제외)
    func fetchSmartCollections(excludingRecent: Bool = true) -> [PHAssetCollection] {
        var collections: [PHAssetCollection] = []
        
        let fetchResult = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: nil
        )
        
        fetchResult.enumerateObjects { collection, _, _ in
            // 최근 항목 중복 제거 옵션
            if excludingRecent && collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                return
            }
            collections.append(collection)
        }
        
        return collections
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
