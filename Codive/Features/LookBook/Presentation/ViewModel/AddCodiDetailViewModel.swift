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
    
    var codiPayloads: [Payloads] {
        return images.enumerated().map { (index, entity) in
            Payloads(
                clothId: Int64(entity.id),
                locationX: Double(entity.position.x),
                locationY: Double(entity.position.y),
                ratio: Double(entity.scale),
                degree: Double(entity.rotation),
                order: Int32(index+1) // 배열의 순서가 곧 레이어 순서(order)가 됩니다.
            )
        }
    }
    
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

    func handleComplete() {
        let finalData = codiPayloads // [Payloads] 배열 가져오기
        
        print("--- 🔽 Codi Payloads 상세 정보 (총 \(finalData.count)개) ---")
        
        if finalData.isEmpty {
            print("선택된 아이템이 없습니다.")
        } else {
            // 방법 1: dump 사용 (객체 구조 전체를 상세히 출력)
            dump(finalData)
            
            // 방법 2: 가독성 있게 직접 출력하고 싶은 경우
            /*
            for (index, payload) in finalData.enumerated() {
                print("""
                [순서: \(index)]
                - clothId: \(payload.clothId)
                - 위치: (\(payload.locationX), \(payload.locationY))
                - 배율(ratio): \(payload.ratio)
                - 각도(degree): \(payload.degree)
                - 레이어 순서(order): \(payload.order)
                ------------------------------------------
                """)
            }
            */
        }
        
        print("--- 🔼 출력 완료 ---")

        // 실제 완료 처리 (API 호출 등)
        // navigationRouter.navigateBack()
    }
}
