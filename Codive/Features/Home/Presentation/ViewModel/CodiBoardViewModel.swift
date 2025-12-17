//
//  CodiBoardViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

@MainActor
final class CodiBoardViewModel: ObservableObject, DraggableImageViewModelProtocol {
    
    // MARK: - Properties
    @Published var isConfirmed: Bool = false
    @Published var images: [DraggableImageEntity] = []
    @Published var currentlyDraggedID: Int?

    private let useCase: HomeUseCase
    private let navigationRouter: NavigationRouter

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: HomeUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        loadInitialData()
    }

    // MARK: - Data Loading
    private func loadInitialData() {
        images = useCase.loadCodiBoardImages()
    }

    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }

    // MARK: - Actions
    func handleConfirmCodi() {
        useCase.saveCodiItems(images)
        isConfirmed = true
    }

    // MARK: - Image Manipulation (DraggableImageViewModelProtocol)
    func bringImageToFront(id: Int) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            let tapped = images.remove(at: index)
            images.append(tapped)
        }
    }

    func updateImagePosition(id: Int, newPosition: CGPoint) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].position = newPosition
        }
    }
    
    func updateImageScale(id: Int, newScale: CGFloat) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].scale = newScale
        }
    }
    
    func updateImageRotation(id: Int, newRotation: Double) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].rotationAngle = newRotation
        }
    }
}
