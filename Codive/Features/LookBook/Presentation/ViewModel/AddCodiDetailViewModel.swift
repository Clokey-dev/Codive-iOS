//
//  AddCodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

@MainActor
final class AddCodiDetailViewModel: ObservableObject, DraggableImageViewModelProtocol {
    
    // MARK: - Properties (State: Product & Filter)
    
    @Published var products: [ProductItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "전체"
    @Published var selectedProductIds: Set<Int> = []
    
    // MARK: - Properties (State: Board & Images)
    
    @Published var images: [DraggableImageEntity] = []
    @Published var currentlyDraggedID: Int?
    @Published var selectedImageID: Int? // 추가된 속성
    var boardSize: CGFloat = 300
    
    // MARK: - Properties (Dependencies)
    
    private let navigationRouter: NavigationRouter
    private let productUseCase: ProductUseCase
    private let lookbookId: Int
    
    // MARK: - Computed Properties
    
    /// 검색어 및 카테고리에 의해 필터링된 상품 목록
    var filteredProducts: [ProductItem] {
        products.filter { product in
            let matchCategory = (selectedCategory == "전체") // TODO: 카테고리 필터 로직 구체화 필요
            let matchSearch = searchText.isEmpty ||
                (product.name?.contains(searchText) ?? false) ||
                (product.brand?.contains(searchText) ?? false)
            
            return matchCategory && matchSearch
        }
    }
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        productUseCase: ProductUseCase,
        lookbookId: Int
    ) {
        self.navigationRouter = navigationRouter
        self.productUseCase = productUseCase
        self.lookbookId = lookbookId
        
        // 초기 상품 목록 로드
        Task { await fetchProducts() }
    }
    
    // MARK: - API / Data Fetching
    
    /// 서버로부터 선택 가능한 상품 목록을 가져옵니다.
    func fetchProducts() async {
        do {
            self.products = try await productUseCase.fetchProductList()
        } catch {
            handleError(error)
        }
    }
}

// MARK: - Product Selection Logic

extension AddCodiDetailViewModel {
    
    /// 상품 선택 상태를 토글하고 보드에 이미지를 추가/제거합니다.
    func toggleProductSelection(_ product: ProductItem) {
        if selectedProductIds.contains(product.id) {
            // 선택 해제 시 이미지 제거
            selectedProductIds.remove(product.id)
            removeImage(productId: product.id)
        } else if selectedProductIds.count < 10 {
            // 최대 10개까지 선택 가능 및 이미지 추가
            selectedProductIds.insert(product.id)
            addImage(from: product)
        }
    }
}

// MARK: - Image Management (Private)

private extension AddCodiDetailViewModel {
    
    /// 보드 중앙 부근에 새로운 이미지를 추가합니다.
    func addImage(from product: ProductItem) {
        let centerX = boardSize / 2
        let centerY = boardSize / 2
        
        // 이미지 겹침 방지를 위한 랜덤 오프셋
        let randomOffsetX = CGFloat.random(in: -30...30)
        let randomOffsetY = CGFloat.random(in: -30...30)
        
        let newImage = DraggableImageEntity(
            id: product.id,
            name: product.imageUrl ?? product.imageName ?? "",
            position: CGPoint(
                x: centerX + randomOffsetX,
                y: centerY + randomOffsetY
            ),
            scale: 1.0,
            rotationAngle: 0
        )
        
        images.append(newImage)
    }
    
    /// 보드에서 특정 상품의 이미지를 제거합니다.
    func removeImage(productId: Int) {
        images.removeAll { $0.id == productId }
        // 삭제된 이미지가 선택되어 있었다면 선택 해제
        if selectedImageID == productId {
            selectedImageID = nil
        }
    }
    
    /// 에러 로그 처리
    func handleError(_ error: Error) {
        print("DEBUG: 상품 목록 로드 실패 - \(error.localizedDescription)")
    }
}

// MARK: - DraggableImageViewModelProtocol Implementation

extension AddCodiDetailViewModel {
    
    /// 탭한 이미지를 레이어 최상단으로 가져옵니다.
    func bringImageToFront(id: Int) {
        guard let index = images.firstIndex(where: { $0.id == id }) else { return }
        let tappedImage = images.remove(at: index)
        images.append(tappedImage)
    }
    
    /// 이미지의 현재 좌표를 업데이트합니다.
    func updateImagePosition(id: Int, newPosition: CGPoint) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].position = newPosition
        }
    }
    
    /// 이미지의 확대/축소 비율을 업데이트합니다.
    func updateImageScale(id: Int, newScale: CGFloat) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].scale = newScale
        }
    }
    
    /// 이미지의 회전 각도를 업데이트합니다.
    func updateImageRotation(id: Int, newRotation: Double) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].rotationAngle = newRotation
        }
    }
}

// MARK: - Navigation & Actions

extension AddCodiDetailViewModel {
    
    /// 이미지 선택/해제 (추가된 메서드)
    func selectImage(id: Int?) {
        selectedImageID = id
    }
    
    // MARK: - Navigation & Actions
    
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    /// 구성을 완료하고 코디 추가 화면으로 이동합니다.
    func handleComplete() {
        navigationRouter.navigateBack()
    }
}
