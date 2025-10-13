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
    private let navigationRouter: NavigationRouter
    
    // MARK: - Computed Properties
    var isCompleteEnabled: Bool {
        !selectedPhotos.isEmpty
    }
    
    var selectedAlbumTitle: String {
        selectedAlbum?.title ?? "최근 항목"
    }
    
    // MARK: - Initializer
    init(fetchPhotosUseCase: FetchPhotosUseCase, navigationRouter: NavigationRouter) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - Methods
    func requestAuthorization() async {
        authorizationStatus = await fetchPhotosUseCase.requestAuthorization()
        
        if authorizationStatus == .authorized || authorizationStatus == .limited {
            loadAlbums()
        }
    }
    
    func loadAlbums() {
        albums = fetchPhotosUseCase.fetchAlbums()
        
        if let firstAlbum = albums.first {
            selectAlbum(firstAlbum)
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
    
    func handleCameraCapture() {
        // 카메라로 촬영 후 갤러리 새로고침
        loadAlbums()
    }
    
    func completeSelection() {
        // TODO: 선택 완료 액션
        print("선택된 사진: \(selectedPhotos.count)장")
        navigationRouter.navigateBack()
    }
    
    func dismissView() {
        navigationRouter.navigateBack()
    }
}
