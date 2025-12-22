//
//  AddCodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

@MainActor
final class AddCodiDetailViewModel: ObservableObject, DraggableImageViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    
    // MARK: - Published State (Product / Filter)
    
    @Published var products: [ProductItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "전체"
    @Published var selectedProductIds: Set<Int> = []
    
    // MARK: - Draggable Image State (Board)
    
    @Published var images: [DraggableImageEntity] = []
    @Published var currentlyDraggedID: Int?
    var boardSize: CGFloat = 300
    
    // MARK: - Computed Properties
    
    var filteredProducts: [ProductItem] {
        products.filter { product in
            let matchCategory = (selectedCategory == "전체")
            let matchSearch =
            searchText.isEmpty ||
            (product.name?.contains(searchText) ?? false) ||
            (product.brand?.contains(searchText) ?? false)
            return matchCategory && matchSearch
        }
    }
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        useCase: LookBookUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        
        Task { await fetchProducts() }
    }
    
    // MARK: - Data Fetching
    
    func fetchProducts() async {
        do {
            self.products = try await useCase.fetchProductList()
        } catch {
            print("상품 목록 로드 실패: \(error)")
        }
    }
    
    // MARK: - Product Selection Logic
    
    func toggleProductSelection(_ product: ProductItem) {
        if selectedProductIds.contains(product.id) {
            // 선택 해제 → 이미지 제거
            selectedProductIds.remove(product.id)
            removeImage(productId: product.id)
        } else if selectedProductIds.count < 10 {
            // 선택 → 이미지 추가 (최대 10개 제한)
            selectedProductIds.insert(product.id)
            addImage(from: product)
        }
    }
    
    // MARK: - Image Management
    
    private func addImage(from product: ProductItem) {
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
    
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func handleComplete() {
        let data = SelectedCodi(
            codiId: 0,
            imageURL: "",
            name: "",
            memo: "",
            combinedItems: images
        )
        
        navigationRouter.navigate(
            to: .addCodi(
                lookbookId: 0,
                selectedCodiData: data
            )
        )
    }
}
