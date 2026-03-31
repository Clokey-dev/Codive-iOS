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
    @Published var selectedIds: Set<String> = []
    @Published var selectionOrder: [String] = []  // 순서 유지용 배열
    @Published var isAlbumSheetPresented = false
    @Published var isCameraPresented = false
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isCompletingSelection = false
    @Published var isClothInfoPresented = false
    @Published var isAIAddEnabled = false
    @Published var isDontShowTodayChecked = false

    private let fetchPhotosUseCase: FetchPhotosUseCase
    private let processImageUseCase: ProcessImageUseCase
    private let navigationRouter: NavigationRouter
    private var cancellables = Set<AnyCancellable>()
    private var hasShownClothInfoInSession = false
    private let flowType: PhotoEditFlowType

    // MARK: - Computed Properties
    var isClothFlow: Bool {
        flowType == .cloth
    }

    var isCompleteEnabled: Bool {
        !selectedIds.isEmpty
    }

    /// 선택된 PhotoAsset 목록 (순서 유지)
    var selectedPhotos: [PhotoAsset] {
        selectionOrder.compactMap { id in
            photos.first { $0.id == id }
        }
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

        if flowType == .cloth {
            $isAIAddEnabled
                .dropFirst()
                .filter { $0 }
                .sink { [weak self] _ in
                    self?.showClothInfoIfNeeded()
                }
                .store(in: &cancellables)
        }
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
        if selectedIds.contains(photo.id) {
            selectedIds.remove(photo.id)
            selectionOrder.removeAll { $0 == photo.id }
        } else {
            selectedIds.insert(photo.id)
            selectionOrder.append(photo.id)
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
            selectedIds.removeAll()
            selectionOrder.removeAll()
            await loadAlbums()
        }
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) async {
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } catch {
            #if DEBUG
            print("[Photo] 사진 저장 실패: \(error)")
            #endif
        }
    }
    
    func completeSelection() {
        isCompletingSelection = true

        let photosToProcess = selectedPhotos
        let targetSize = CGSize(width: 1080, height: 1080)
        let currentFlowType = flowType
        let cropUseCase = processImageUseCase
        let fetchUseCase = fetchPhotosUseCase

        Task.detached(priority: .userInitiated) {
            let selectedPhotoItems: [SelectedPhoto] = await withTaskGroup(
                of: (Int, SelectedPhoto?).self
            ) { group in
                for (index, photo) in photosToProcess.enumerated() {
                    group.addTask {
                        guard let image = await fetchUseCase.loadThumbnail(
                            for: photo.asset,
                            size: targetSize
                        ) else {
                            return (index, nil)
                        }

                        let croppedImage: UIImage
                        switch currentFlowType {
                        case .record:
                            croppedImage = cropUseCase.cropTo3_4Ratio(image)
                        case .cloth:
                            croppedImage = cropUseCase.cropTo1_1Ratio(image)
                        }

                        let displayReady = await croppedImage.byPreparingForDisplay() ?? croppedImage
                        let originalReady = await image.byPreparingForDisplay() ?? image

                        var selectedPhoto = SelectedPhoto(
                            id: photo.id,
                            croppedImage: displayReady,
                            order: index + 1
                        )
                        selectedPhoto.originalImage = originalReady
                        return (index, selectedPhoto)
                    }
                }

                var results: [(Int, SelectedPhoto?)] = []
                for await result in group {
                    results.append(result)
                }
                return results
                    .sorted { $0.0 < $1.0 }
                    .compactMap { $0.1 }
            }

            await MainActor.run {
                self.isCompletingSelection = false

                switch self.flowType {
                case .record:
                    self.navigationRouter.navigate(to: .photoEdit(photos: selectedPhotoItems))
                case .cloth:
                    self.navigationRouter.navigate(to: .photoEditForCloth(photos: selectedPhotoItems, isAIEnabled: self.isAIAddEnabled))
                }
            }
        }
    }
    
    func resetSelection() {
        selectedIds.removeAll()
        selectionOrder.removeAll()
    }
    
    func dismissView() {
        navigationRouter.navigateBack()
    }

    // MARK: - Cloth Info Guide
    private static let clothInfoDismissDateKey = "cloth_info_dismiss_date"

    private func showClothInfoIfNeeded() {
        guard !hasShownClothInfoInSession else { return }

        let today = Self.todayDateString()
        let savedDate = UserDefaults.standard.string(forKey: Self.clothInfoDismissDateKey)

        if savedDate != today {
            hasShownClothInfoInSession = true
            isClothInfoPresented = true
            isDontShowTodayChecked = false
        }
    }

    func dismissClothInfo() {
        if isDontShowTodayChecked {
            UserDefaults.standard.set(Self.todayDateString(), forKey: Self.clothInfoDismissDateKey)
        }
        isClothInfoPresented = false
    }

    private static func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: Date())
    }
}
