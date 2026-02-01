//
//  AddCodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

@MainActor
final class AddCodiDetailViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "전체"
    @Published var selectedProductIds: Set<Int> = []
    @Published var clothItems: [ProductItem] = []
    
    @Published var images: [DraggableImageEntity] = []
    @Published var currentlyDraggedID: Int?
    @Published var selectedImageID: Int?
    var boardSize: CGFloat = 300
    
    private let navigationRouter: NavigationRouter
    private let productUseCase: ProductUseCase
    private let lookbookId: Int
    
    init(navigationRouter: NavigationRouter, productUseCase: ProductUseCase, lookbookId: Int) {
        self.navigationRouter = navigationRouter
        self.productUseCase = productUseCase
        self.lookbookId = lookbookId
        Task { await fetchClothItems() }
    }

    func fetchClothItems() async {
        do {
            clothItems = try await productUseCase.execute(category: selectedCategory)
        } catch {
            clothItems = []
        }
    }

    func toggleProductSelection(_ product: ProductItem) {
        if selectedProductIds.contains(product.id) {
            selectedProductIds.remove(product.id)
            images.removeAll { $0.id == product.id }
        } else if selectedProductIds.count < 10 {
            selectedProductIds.insert(product.id)
            
            // 신규 이미지 추가 시 중앙 좌표 근처로 설정
            let newImage = DraggableImageEntity(
                id: product.id,
                name: product.imageUrl ?? product.imageName ?? "",
                position: .zero,
                scale: 1.0,
                rotation: 0
            )
            images.append(newImage)
        }
    }

    private func addImage(from product: ProductItem) {
        let centerX = boardSize / 2
        let centerY = boardSize / 2
        let randomOffsetX = CGFloat.random(in: -30...30)
        let randomOffsetY = CGFloat.random(in: -30...30)
        
        let newImage = DraggableImageEntity(
            id: product.id,
            name: product.imageUrl ?? product.imageName ?? "",
            position: CGPoint(x: centerX + randomOffsetX, y: centerY + randomOffsetY),
            scale: 1.0,
            rotation: 0
        )
        images.append(newImage)
    }

    private func removeImage(productId: Int) {
        images.removeAll { $0.id == productId }
        if selectedImageID == productId { selectedImageID = nil }
    }

    // 제스처 결과 반영 메서드들
    func bringImageToFront(id: Int) {
        guard let index = images.firstIndex(where: { $0.id == id }) else { return }
        let tappedImage = images.remove(at: index)
        images.append(tappedImage)
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
            images[index].rotation = newRotation
        }
    }
    
    func selectImage(id: Int?) {
        selectedImageID = id
    }
    
    func handleBackTap() { navigationRouter.navigateBack() }
    func handleComplete() { navigationRouter.navigateBack() }
}
