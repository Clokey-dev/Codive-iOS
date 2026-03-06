//
//  PhotoEditViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Foundation
import UIKit
import Combine

// MARK: - PhotoEditFlowType
enum PhotoEditFlowType {
    case record  // 기록 추가 플로우
    case cloth   // 옷 추가 플로우
}

// MARK: - PhotoEditViewModel
@MainActor
final class PhotoEditViewModel: ObservableObject {

    // MARK: - Properties
    @Published var selectedPhotos: [SelectedPhoto]
    @Published var currentIndex: Int = 0
    @Published var isEditingMode: Bool = false
    @Published var showExitAlert: Bool = false

    private let navigationRouter: NavigationRouter
    private let flowType: PhotoEditFlowType
    private let isAIEnabled: Bool
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var allowZoomOut: Bool {
        flowType == .cloth
    }

    var currentPhoto: SelectedPhoto? {
        guard selectedPhotos.indices.contains(currentIndex) else { return nil }
        return selectedPhotos[currentIndex]
    }
    
    var canMoveBack: Bool {
        currentIndex > 0
    }
    
    var canMoveForward: Bool {
        currentIndex < selectedPhotos.count - 1
    }

    var aspectRatio: CGFloat {
        switch flowType {
        case .record:
            return 3.0 / 4.0
        case .cloth:
            return 1.0
        }
    }
    
    // MARK: - Initializer
    init(
        selectedPhotos: [SelectedPhoto],
        navigationRouter: NavigationRouter,
        flowType: PhotoEditFlowType = .record,
        isAIEnabled: Bool = false
    ) {
        self.selectedPhotos = selectedPhotos.sorted { $0.order < $1.order }
        self.navigationRouter = navigationRouter
        self.flowType = flowType
        self.isAIEnabled = isAIEnabled
    }
    
    // MARK: - Methods
    func moveToPrevious() {
        guard canMoveBack else { return }
        currentIndex -= 1
    }
    
    func moveToNext() {
        guard canMoveForward else { return }
        currentIndex += 1
    }
    
    func startEditing() {
        isEditingMode = true
    }
    
    func updateCroppedImage(_ image: UIImage) {
        guard selectedPhotos.indices.contains(currentIndex) else { return }
        selectedPhotos[currentIndex].croppedImage = image
        isEditingMode = false
    }
    
    func cancelEditing() {
        isEditingMode = false
    }
    
    func reorderPhotos(from source: IndexSet, to destination: Int) {
        selectedPhotos.move(fromOffsets: source, toOffset: destination)
        
        // 순서 재정렬
        for index in selectedPhotos.indices {
            selectedPhotos[index].order = index + 1
        }
    }
    
    func completeEditing() {
        cleanupOriginalImages()
        switch flowType {
        case .record:
            navigationRouter.navigate(to: .recordDetail(photos: selectedPhotos))
        case .cloth:
            navigationRouter.navigate(to: .clothAdd(photos: selectedPhotos, isAIEnabled: isAIEnabled))
        }
    }
    
    func dismissView() {
        showExitAlert = true
    }

    func confirmExit() {
        cleanupOriginalImages()
        navigationRouter.navigateBack()
    }

    // MARK: - Private Methods

    private func cleanupOriginalImages() {
        for photo in selectedPhotos {
            photo.cleanupOriginal()
        }
    }
}
