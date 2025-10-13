//
//  RecordAddViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Foundation
import Photos

// MARK: - RecordAddViewModel
@MainActor
final class RecordAddViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var albums: [PhotoAlbum] = []
    @Published var selectedAlbum: PhotoAlbum?
    @Published var photos: [PhotoAsset] = []
    @Published var selectedPhotos: [PhotoAsset] = []
    @Published var isAlbumSheetPresented = false
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    private let fetchPhotosUseCase: FetchPhotosUseCase
    
    // MARK: - Computed Properties
    var isCompleteEnabled: Bool {
        !selectedPhotos.isEmpty
    }
    
    var selectedAlbumTitle: String {
        selectedAlbum?.title ?? "최근 항목"
    }
    
    // MARK: - Initializer
    init(fetchPhotosUseCase: FetchPhotosUseCase) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
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
            photos[index].isSelected.toggle()
            
            if photos[index].isSelected {
                // 선택됨 - 순서 부여
                let order = selectedPhotos.count + 1
                photos[index].selectionOrder = order
                selectedPhotos.append(photos[index])
            } else {
                // 선택 해제 - 순서 재정렬
                selectedPhotos.removeAll { $0.id == photo.id }
                photos[index].selectionOrder = nil
                reorderSelection()
            }
        }
    }
    
    private func reorderSelection() {
        for (index, photo) in selectedPhotos.enumerated() {
            if let photoIndex = photos.firstIndex(where: { $0.id == photo.id }) {
                photos[photoIndex].selectionOrder = index + 1
            }
        }
    }
    
    func showAlbumSheet() {
        isAlbumSheetPresented = true
    }
    
    func completeSelection() {
        // TODO: 선택 완료 액션
        print("선택된 사진: \(selectedPhotos.count)장")
    }
}
