//
//  AddCodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI
import Combine

@MainActor
final class AddCodiDetailViewModel: ObservableObject {
    
    // 외부에서 구독할 수 있도록 static 전역 스트림을 생성합니다.
    static let codiDataUpdated = PassthroughSubject<CodiTransferData, Never>()
    
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "전체"
    @Published var selectedProductIds: Set<Int> = []
    @Published var clothItems: [ProductItem] = []
    
    @Published var images: [DraggableImageEntity] = []
    @Published var currentlyDraggedID: Int?
    @Published var selectedImageID: Int?
    @Published var capturedImageString: String? = nil
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
    
    // MARK: - View Capture Logic
    func captureBoard(view: some View) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        
        // 렌더링 시점에 이미지가 준비되었는지 확인
        if let uiImage = renderer.uiImage {
            // MARK: - JPG 타입으로 변환 (압축률 0.8)
            // pngData() 대신 jpegData()를 사용하여 JPG 포맷 데이터를 추출합니다.
            if let jpgData = uiImage.jpegData(compressionQuality: 0.8) {
                let base64String = jpgData.base64EncodedString()
                self.capturedImageString = base64String
                
                print("--- 📸 JPG 캡처 완료 ---")
                // 디코딩 사이트에서 확인 시 앞에 붙여야 할 헤더 정보
                print("data:image/jpeg;base64,\(base64String.prefix(20))...")
            }
        }
    }
    
    func handleBackTap() { navigationRouter.navigateBack() }
    
    func handleComplete() {
        guard let imageString = capturedImageString else {
            print("캡처된 이미지가 없어 전송을 취소합니다.")
            return
        }
        
        let finalData = codiPayloads
        
        // 1. 데이터를 하나로 묶음
        let dataToTransfer = CodiTransferData(payloads: finalData, imageString: imageString)
        
        // 2. Combine 스트림을 통해 데이터 발사!
        Self.codiDataUpdated.send(dataToTransfer)
        
        print("--- 🚀 AddCodiView로 데이터 전송 완료 ---")
        
        // 3. 이전 화면으로 이동
        navigationRouter.navigateBack()
    }
}
