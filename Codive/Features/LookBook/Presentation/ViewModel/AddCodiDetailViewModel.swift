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
    private let lookbookId: Int64

    var codiPayloads: [Payloads] {
        return images.enumerated().map { (index, entity) in
            // 보드 중앙이 (0,0)인 경우를 가정하여 좌상단 (0,0) 기준 비율로 변환
            // 예: boardSize가 300일 때, 오프셋 -150은 0.0, 0은 0.5, 150은 1.0이 됨
            let normalizedX = (entity.position.x + (boardSize / 2)) / boardSize
            let normalizedY = (entity.position.y + (boardSize / 2)) / boardSize
            
            return Payloads(
                clothId: Int64(entity.id),
                locationX: Double(normalizedX),
                locationY: Double(normalizedY),
                ratio: Double(entity.scale),
                degree: Double(entity.rotation),
                order: Int32(index + 1)
            )
        }
    }
    
    init(navigationRouter: NavigationRouter, productUseCase: ProductUseCase, lookbookId: Int64) {
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
    
    func captureBoard(view: some View) async {
            let renderer = ImageRenderer(content: view)
            renderer.scale = UIScreen.main.scale
            
            guard let uiImage = renderer.uiImage,
                  let jpgData = uiImage.jpegData(compressionQuality: 0.8) else {
                print("❌ 이미지 캡처 실패")
                return
            }
            
            print("--- 📸 JPG 캡처 완료 (크기: \(jpgData.count / 1024)KB) ---")
            
            do {
                // UseCase를 통해 이미지 업로드
                let uploadedURL = try await productUseCase.execute(jpgData: jpgData)
                self.capturedImageString = uploadedURL
                
                print("✅ 최종 이미지 URL 저장 완료")
            } catch {
                print("❌ 이미지 업로드 실패: \(error.localizedDescription)")
                // TODO: 사용자에게 에러 알림 표시
            }
        }
    
    func handleBackTap() { navigationRouter.navigateBack() }
    
    func handleComplete() async {
            guard let imageURL = capturedImageString else {
                print("⚠️ 업로드된 이미지 URL이 없어 전송을 취소합니다.")
                return
            }
            
            let finalData = codiPayloads
            let dataToTransfer = CodiTransferData(
                payloads: finalData,
                imageString: imageURL // 이제 실제 https:// URL
            )
            
            Self.codiDataUpdated.send(dataToTransfer)
            
            print("--- 🚀 AddCodiView로 데이터 전송 완료 ---")
            print("📍 Image URL: \(imageURL)")
            print("📍 Payloads 개수: \(finalData.count)")
            
            navigationRouter.navigateBack()
        }
}
