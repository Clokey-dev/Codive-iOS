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
    
    private let codiBoardUseCase: CodiBoardUseCase
    private let navigationRouter: NavigationRouter
    private weak var homeViewModel: HomeViewModel?
    
    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        codiBoardUseCase: CodiBoardUseCase,
        homeViewModel: HomeViewModel? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.codiBoardUseCase = codiBoardUseCase
        self.homeViewModel = homeViewModel
        loadInitialData()
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        images = codiBoardUseCase.loadCodiBoardImages()
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    // MARK: - Actions
    func handleConfirmCodi() {
        codiBoardUseCase.saveCodiItems(images)
        
        // 코디 이미지 URL 생성 (실제로는 저장된 이미지의 URL을 가져와야 함)
        let imageURL = images.first?.imageURL
        
        // 뒤로 이동
        navigationRouter.navigateBack()
        
        // 팝업 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.homeViewModel?.showCompletionPopup(imageURL: imageURL)
        }
        
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
