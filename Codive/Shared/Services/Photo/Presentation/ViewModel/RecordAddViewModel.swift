//
//  RecordAddViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Foundation
import Photos
import UIKit
import Combine

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
    @Published var isCompletingSelection = false
    @Published var isClothInfoPresented = false

    private let fetchPhotosUseCase: FetchPhotosUseCase
    private let processImageUseCase: ProcessImageUseCase
    private let navigationRouter: NavigationRouter
    private let flowType: PhotoEditFlowType
    
    // MARK: - Computed Properties
    var isCompleteEnabled: Bool {
        !selectedPhotos.isEmpty
    }

    var selectedAlbumTitle: String {
        selectedAlbum?.title ?? TextLiteral.Add.recordRecentAlbum
    }

    var navigationTitle: String {
        switch flowType {
        case .record:
            return TextLiteral.Add.recordTitle
        case .cloth:
            return "옷 추가"
        }
    }
    
    // MARK: - Initializer
    init(
        fetchPhotosUseCase: FetchPhotosUseCase,
        processImageUseCase: ProcessImageUseCase,
        navigationRouter: NavigationRouter,
        flowType: PhotoEditFlowType = .record
    ) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
        self.processImageUseCase = processImageUseCase
        self.navigationRouter = navigationRouter
        self.flowType = flowType
    }
    
    // MARK: - Image Loading
    func loadThumbnail(for asset: PHAsset, size: CGSize) async -> UIImage? {
        return await fetchPhotosUseCase.loadThumbnail(for: asset, size: size)
    }
    
    // MARK: - Methods
    func requestAuthorization() async {
        authorizationStatus = await fetchPhotosUseCase.requestAuthorization()
        
        if authorizationStatus == .authorized || authorizationStatus == .limited {
            await loadAlbums()

            if flowType == .cloth {
                isClothInfoPresented = true
            }
        }
    }

    func loadAlbums() async {
        let (fetchedAlbums, defaultAlbum) = await fetchPhotosUseCase.fetchAlbumsWithDefault()
        
        albums = fetchedAlbums
        
        if let defaultAlbum = defaultAlbum {
            await selectAlbum(defaultAlbum)
        }
    }
    
    func selectAlbum(_ album: PhotoAlbum) async {
        selectedAlbum = album
        photos = await fetchPhotosUseCase.fetchPhotos(from: album)
        isAlbumSheetPresented = false
    }
    
    func togglePhotoSelection(_ photo: PhotoAsset) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            var updatedPhoto = photos[index]
            updatedPhoto.isSelected.toggle()
            
            if updatedPhoto.isSelected {
                let order = selectedPhotos.count + 1
                updatedPhoto.selectionOrder = order
                selectedPhotos.append(updatedPhoto)
            } else {
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
        Task {
            await saveImageToPhotoLibrary(image)
            selectedPhotos.removeAll()
            await loadAlbums()
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
            isCompletingSelection = true
            
            var selectedPhotoItems: [SelectedPhoto] = []
            
            let photosToProcess = selectedPhotos
            let targetSize = CGSize(width: 1200, height: 1200)
            
            for (index, photo) in photosToProcess.enumerated() {
                if let image = await fetchPhotosUseCase.loadThumbnail(
                    for: photo.asset,
                    size: targetSize
                ) {
                    let croppedImage: UIImage
                    switch flowType {
                    case .record:
                        croppedImage = processImageUseCase.cropTo3_4Ratio(image)
                    case .cloth:
                        croppedImage = processImageUseCase.cropTo1_1Ratio(image)
                    }

                    let selectedPhoto = SelectedPhoto(
                        id: photo.id,
                        originalImage: image,
                        croppedImage: croppedImage,
                        order: index + 1
                    )
                    selectedPhotoItems.append(selectedPhoto)
                }
            }
            
            switch flowType {
            case .record:
                navigationRouter.navigate(to: .photoEdit(photos: selectedPhotoItems))
            case .cloth:
                navigationRouter.navigate(to: .photoEditForCloth(photos: selectedPhotoItems))
            }
                    
            resetSelection()
            isCompletingSelection = false
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
