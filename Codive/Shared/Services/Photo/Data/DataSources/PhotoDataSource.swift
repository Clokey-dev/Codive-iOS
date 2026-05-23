//
//  PhotoDataSource.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Photos
import UIKit
import ImageIO

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

    /// ImageIO 다운샘플링으로 이미지 로드 (원본 전체 디코딩 없이 타겟 크기만 생성)
    func loadImage(for asset: PHAsset, size: CGSize) async -> UIImage? {
        guard let imageData = await loadImageData(for: asset) else { return nil }
        return downsample(data: imageData, to: size)
    }

    private func loadImageData(for asset: PHAsset) async -> Data? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            imageManager.requestImageDataAndOrientation(
                for: asset,
                options: options
            ) { data, _, _, _ in
                continuation.resume(returning: data)
            }
        }
    }

    private func downsample(data: Data, to size: CGSize) -> UIImage? {
        let maxDimension = max(size.width, size.height)

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ]

        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
