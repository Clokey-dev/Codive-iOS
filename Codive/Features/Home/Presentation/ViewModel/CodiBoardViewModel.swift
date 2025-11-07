//
//  CodiBoardViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

@MainActor
final class CodiBoardViewModel: ObservableObject {
    @Published var isConfirmed: Bool = false
    @Published var images: [DraggableImageEntity] = []
    @Published var currentlyDraggedID: Int?

    private let useCase: HomeUseCase
    private let navigationRouter: NavigationRouter

    init(navigationRouter: NavigationRouter, useCase: HomeUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        loadInitialData()
    }

    private func loadInitialData() {
        images = useCase.loadCodiItems()
    }

    func handleBackTap() {
        navigationRouter.navigateBack()
    }

    func handleConfirmCodi() {
        useCase.saveCodiItems(images)
        isConfirmed = true
    }

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
}
