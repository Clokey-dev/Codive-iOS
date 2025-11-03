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
    
    // MARK: - Authorization
    func requestAuthorization() async -> PHAuthorizationStatus {
        return await repository.requestPhotoLibraryAuthorization()
    }
    
    // MARK: - Fetch Albums
    
    /// 모든 앨범 - 이미 우선순위 정렬되어 있음
    func fetchAlbums() -> [PhotoAlbum] {
        return repository.fetchAlbums()
    }
    
    /// 앨범 목록과 기본으로 선택할 앨범을 함께 반환 (비동기)
    /// 비즈니스 규칙: 최근 항목이 있으면 최근 항목, 없으면 첫 번째 앨범
    func fetchAlbumsWithDefault() async -> (albums: [PhotoAlbum], defaultAlbum: PhotoAlbum?) {
        return await Task.detached(priority: .userInitiated) {
            let albums = self.repository.fetchAlbums()
            
            // 최근 항목 찾기
            let defaultAlbum = albums.first {
                $0.collection.assetCollectionSubtype == .smartAlbumUserLibrary
            } ?? albums.first
            
            return (albums, defaultAlbum)
        }.value
    }

    // MARK: - Fetch Photos
    
    func fetchPhotos(from album: PhotoAlbum) async -> [PhotoAsset] {
        return await Task.detached(priority: .userInitiated) {
            self.repository.fetchPhotos(from: album)
        }.value
    }
    
    /// 여러 앨범에서 최근 사진들을 합쳐서 가져오기
    func fetchRecentPhotos(limit: Int = 100) -> [PhotoAsset] {
        let albums = repository.fetchAlbums()
        
        // 최근 항목 앨범 찾기
        guard let recentAlbum = albums.first(where: {
            $0.collection.assetCollectionSubtype == .smartAlbumUserLibrary
        }) else {
            return []
        }
        
        let allPhotos = repository.fetchPhotos(from: recentAlbum)
        return Array(allPhotos.prefix(limit))
    }
    
    // MARK: - Load Image
    
    func loadThumbnail(for asset: PHAsset, size: CGSize) async -> UIImage? {
        return await repository.loadThumbnail(for: asset, size: size)
    }
    
    /// 여러 에셋의 썸네일을 한번에 로드 - 병렬 처리
    func loadThumbnails(
        for assets: [PHAsset],
        size: CGSize
    ) async -> [String: UIImage] {
        await withTaskGroup(of: (String, UIImage?).self) { group in
            for asset in assets {
                group.addTask {
                    let image = await self.repository.loadThumbnail(for: asset, size: size)
                    return (asset.localIdentifier, image)
                }
            }
            
            var results: [String: UIImage] = [:]
            for await (id, image) in group {
                if let image = image {
                    results[id] = image
                }
            }
            return results
        }
    }
}
