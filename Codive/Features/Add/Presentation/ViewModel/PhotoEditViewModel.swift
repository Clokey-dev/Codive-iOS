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
        for (index, _) in selectedPhotos.enumerated() {
            selectedPhotos[index].order = index + 1
        }
    }
    
    func completeEditing() {
        // TODO: 다음 화면으로 이동하면서 selectedPhotos 전달
        print("편집 완료: \(selectedPhotos.count)장")
        navigationRouter.navigateBack()
    }
    
    func dismissView() {
        navigationRouter.navigateBack()
    }
}
