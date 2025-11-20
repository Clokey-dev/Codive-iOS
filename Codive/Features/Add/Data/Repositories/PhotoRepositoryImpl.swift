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
        var albums: [PhotoAlbum] = []
        
        // 1. 최근 항목 (최우선)
        if let recentCollection = dataSource.fetchRecentCollection() {
            if let album = convertToPhotoAlbum(recentCollection) {
                albums.append(album)
            }
        }
        
        // 2. 사용자가 만든 앨범들
        let userCollections = dataSource.fetchUserCollections()
        let userAlbums = userCollections.compactMap { convertToPhotoAlbum($0) }
        albums.append(contentsOf: userAlbums)
        
        // 3. 스마트 앨범들 (최근 항목 제외)
        let smartCollections = dataSource.fetchSmartCollections(excludingRecent: true)
        let smartAlbums = smartCollections.compactMap { convertToPhotoAlbum($0) }
        albums.append(contentsOf: smartAlbums)
        
        return albums
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
    
    // MARK: - Private Helpers

    /// PHAssetCollection을 PhotoAlbum Entity로 변환
    /// 비즈니스 규칙: 사진이 없는 앨범은 제외
    private func convertToPhotoAlbum(_ collection: PHAssetCollection) -> PhotoAlbum? {
        let assets = dataSource.fetchPhotos(from: collection)
        
        // swiftlint:disable:next empty_count
        guard assets.count > 0 else { return nil }
        
        return PhotoAlbum(
            id: collection.localIdentifier,
            title: collection.localizedTitle ?? TextLiteral.Common.unknown,
            count: assets.count,
            collection: collection,
            thumbnail: assets.firstObject
        )
    }
}
