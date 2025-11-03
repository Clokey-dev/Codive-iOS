//
//  RecordAddViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Foundation
import Photos
import UIKit

// MARK: - RecordAddViewModel
@MainActor
final class RecordAddViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var albums: [PhotoAlbum] = []
    @Published var selectedAlbum: PhotoAlbum?
    @Published var photos: [PhotoAsset] = []
    @Published var selectedPhotos: [PhotoAsset] = []
    @Published var isAlbumSheetPresented = false
    @Published var isCameraPresented = false
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    private let fetchPhotosUseCase: FetchPhotosUseCase
    private let processImageUseCase: ProcessImageUseCase
    let navigationRouter: NavigationRouter
    
    // MARK: - Computed Properties
    var isCompleteEnabled: Bool {
        !selectedPhotos.isEmpty
    }
    
    var selectedAlbumTitle: String {
        selectedAlbum?.title ?? TextLiteral.Add.recordRecentAlbum
    }
    
    // MARK: - Initializer
    init(
            fetchPhotosUseCase: FetchPhotosUseCase,
            processImageUseCase: ProcessImageUseCase,
            navigationRouter: NavigationRouter
        ) {
            self.fetchPhotosUseCase = fetchPhotosUseCase
            self.processImageUseCase = processImageUseCase
            self.navigationRouter = navigationRouter
        }
    
    // MARK: - Image Loading
    func loadThumbnail(for asset: PHAsset, size: CGSize) async -> UIImage? {
        return await fetchPhotosUseCase.loadThumbnail(for: asset, size: size)
    }
    
    // MARK: - Methods
    func requestAuthorization() async {
        authorizationStatus = await fetchPhotosUseCase.requestAuthorization()
        
        if authorizationStatus == .authorized || authorizationStatus == .limited {
            loadAlbums()
        }
    }
    
    func loadAlbums() {
        let (fetchedAlbums, defaultAlbum) = fetchPhotosUseCase.fetchAlbumsWithDefault()
        
        albums = fetchedAlbums
        
        if let defaultAlbum = defaultAlbum {
            selectAlbum(defaultAlbum)
        }
    }
    
    func selectAlbum(_ album: PhotoAlbum) {
        selectedAlbum = album
        photos = fetchPhotosUseCase.fetchPhotos(from: album)
        isAlbumSheetPresented = false
    }
    
    func togglePhotoSelection(_ photo: PhotoAsset) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            var updatedPhoto = photos[index]
            updatedPhoto.isSelected.toggle()
            
            if updatedPhoto.isSelected {
                // 선택됨 - 순서 부여
                let order = selectedPhotos.count + 1
                updatedPhoto.selectionOrder = order
                selectedPhotos.append(updatedPhoto)
            } else {
                // 선택 해제 - 순서 재정렬
                selectedPhotos.removeAll { $0.id == photo.id }
                updatedPhoto.selectionOrder = nil
                reorderSelection()
            }
            
            photos[index] = updatedPhoto
        }
    }
    
    private func reorderSelection() {
        selectedPhotos = selectedPhotos.enumerated().map { index, photo in
            var updatedPhoto = photo
            updatedPhoto.selectionOrder = index + 1
            return updatedPhoto
        }
        
        // photos 배열도 업데이트
        for (index, photo) in selectedPhotos.enumerated() {
            if let photoIndex = photos.firstIndex(where: { $0.id == photo.id }) {
                photos[photoIndex].selectionOrder = index + 1
            }
        }
    }
    
    func showAlbumSheet() {
        isAlbumSheetPresented = true
    }
    
    func showCamera() {
        isCameraPresented = true
    }
    
    func handleCameraCapture(image: UIImage) {
        // 사진을 포토 라이브러리에 저장
        Task {
            await saveImageToPhotoLibrary(image)
            // 선택 상태 초기화
            selectedPhotos.removeAll()
            // 저장 후 갤러리 새로고침
            loadAlbums()
        }
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) async {
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } catch {
            print("사진 저장 실패: \(error)")
        }
    }
    
    func completeSelection() {
        Task {
            var selectedPhotoItems: [SelectedPhoto] = []
            
            for (index, photo) in selectedPhotos.enumerated() {
                if let image = await fetchPhotosUseCase.loadThumbnail(
                    for: photo.asset,
                    size: PHImageManagerMaximumSize
                ) {
                    let croppedImage = processImageUseCase.cropTo3_4Ratio(image)
                    
                    let selectedPhoto = SelectedPhoto(
                        id: photo.id,
                        originalImage: image,
                        croppedImage: croppedImage,
                        order: index + 1
                    )
                    selectedPhotoItems.append(selectedPhoto)
                }
            }
            
            navigationRouter.navigate(to: .photoEdit(photos: selectedPhotoItems))
        }
    }
    func resetSelection() {
        selectedPhotos.removeAll()
        for index in photos.indices {
            photos[index].isSelected = false
            photos[index].selectionOrder = nil
        }
    }
    
    func dismissView() {
        navigationRouter.navigateBack()
    }
}
