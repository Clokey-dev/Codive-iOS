//
//  AddCodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

@MainActor
final class AddCodiDetailViewModel: ObservableObject, DraggableImageViewModelProtocol {
    private let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    
    @Published var products: [ProductItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "전체"
    @Published var selectedProductIds: Set<Int> = []
    
    // MARK: - DraggableImageViewModelProtocol
    @Published var images: [DraggableImageEntity] = []
    @Published var currentlyDraggedID: Int?
    
    // 보드 크기 저장 (View에서 설정)
    var boardSize: CGFloat = 300
    
    // 필터링된 상품 리스트
    var filteredProducts: [ProductItem] {
        products.filter { product in
            let matchCategory = (selectedCategory == "전체")
            let matchSearch = searchText.isEmpty ||
                             (product.name?.contains(searchText) ?? false) ||
                             (product.brand?.contains(searchText) ?? false)
            return matchCategory && matchSearch
        }
    }

    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        Task { await fetchProducts() }
    }
    
    func fetchProducts() async {
        do {
            self.products = try await useCase.fetchProductList()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func toggleProductSelection(_ product: ProductItem) {
        if selectedProductIds.contains(product.id) {
            // 선택 해제 - 이미지 제거
            selectedProductIds.remove(product.id)
            removeImage(productId: product.id)
        } else if selectedProductIds.count < 10 {
            // 선택 - 이미지 추가
            selectedProductIds.insert(product.id)
            addImage(from: product)
        }
    }
    
    // MARK: - Image Management
    private func addImage(from product: ProductItem) {
        // 보드 중앙에 이미지 추가 (약간의 랜덤 오프셋 추가로 겹치지 않게)
        let centerX = boardSize / 2
        let centerY = boardSize / 2
        let randomOffsetX = CGFloat.random(in: -30...30)
        let randomOffsetY = CGFloat.random(in: -30...30)
        
        let newImage = DraggableImageEntity(
            id: product.id,
            name: product.imageName,
            position: CGPoint(
                x: centerX + randomOffsetX,
                y: centerY + randomOffsetY
            ),
            scale: 1.0,
            rotationAngle: 0
        )
        images.append(newImage)
    }
    
    private func removeImage(productId: Int) {
        images.removeAll { $0.id == productId }
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
    
    // MARK: - Navigation & Actions
    func handleBackTap() { navigationRouter.navigateBack() }
    
    func handleComplete() {
        print("완료: \(images.count)개 아이템")
        print("선택된 상품 IDs: \(selectedProductIds)")
        // TODO: useCase를 통해 저장 로직 추가
    }
}
