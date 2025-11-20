//
//  PhotoEditViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Foundation
import UIKit
import Combine

// MARK: - PhotoEditViewModel
@MainActor
final class PhotoEditViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var selectedPhotos: [SelectedPhoto]
    @Published var currentIndex: Int = 0
    @Published var isEditingMode: Bool = false
    @Published var showExitAlert: Bool = false

    private let navigationRouter: NavigationRouter
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
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
    
    // MARK: - Initializer
    init(selectedPhotos: [SelectedPhoto], navigationRouter: NavigationRouter) {
        self.selectedPhotos = selectedPhotos.sorted { $0.order < $1.order }
        self.navigationRouter = navigationRouter
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
        navigationRouter.navigate(to: .recordDetail(photos: selectedPhotos))
    }
    
    func dismissView() {
        showExitAlert = true
    }

    func confirmExit() {
        navigationRouter.navigateBack()
    }
}
