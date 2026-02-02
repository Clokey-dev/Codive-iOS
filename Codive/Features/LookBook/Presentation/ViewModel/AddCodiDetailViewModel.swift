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

    static let codiDataUpdated = PassthroughSubject<CodiTransferData, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "전체"
    @Published var selectedProductIds: Set<Int> = []
    @Published var clothItems: [ProductItem] = [] {
        didSet {
            if !clothItems.isEmpty, let pendingData = pendingEditData {
                restoreCodiData(from: pendingData)
                self.pendingEditData = nil
            }
        }
    }

    private var pendingEditData: CodiEditData?
    
    @Published var images: [DraggableImageEntity] = []
    @Published var currentlyDraggedID: Int64?
    @Published var selectedImageID: Int64?
    @Published var capturedImageString: String? = nil
    var boardSize: CGFloat = 300
    
    private let navigationRouter: NavigationRouter
    private let productUseCase: ProductUseCase
    
    var codiPayloads: [Payloads] {
        return images.enumerated().map { (index, entity) in
            let normalizedX = (entity.position.x + (boardSize / 2)) / boardSize
            let normalizedY = (entity.position.y + (boardSize / 2)) / boardSize
            
            let rawDegree = Double(entity.rotation)
            let normalizedDegree = rawDegree.truncatingRemainder(dividingBy: 360)
            let positiveDegree = normalizedDegree < 0 ? normalizedDegree + 360 : normalizedDegree
            
            return Payloads(
                clothId: Int64(entity.id),
                locationX: Double(normalizedX),
                locationY: Double(normalizedY),
                ratio: Double(entity.scale),
                degree: positiveDegree,
                order: Int32(index + 1)
            )
        }
    }
    
    init(navigationRouter: NavigationRouter, productUseCase: ProductUseCase) {
        self.navigationRouter = navigationRouter
        self.productUseCase = productUseCase
        
        setupEditDataSubscription()
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
            images.removeAll { $0.id == Int64(product.id) }
        } else if selectedProductIds.count < 10 {
            selectedProductIds.insert(product.id)
            
            let newImage = DraggableImageEntity(
                id: Int64(product.id),
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
            id: Int64(product.id),
            name: product.imageUrl ?? product.imageName ?? "",
            position: CGPoint(x: centerX + randomOffsetX, y: centerY + randomOffsetY),
            scale: 1.0,
            rotation: 0
        )
        images.append(newImage)
    }

    private func removeImage(productId: Int64) {
        images.removeAll { $0.id == productId }
        if selectedImageID == productId { selectedImageID = nil }
    }
    
    // 제스처 결과 반영 메서드들
    func bringImageToFront(id: Int64) {
        guard let index = images.firstIndex(where: { $0.id == id }) else { return }
        let tappedImage = images.remove(at: index)
        images.append(tappedImage)
    }

    func updateImagePosition(id: Int64, newPosition: CGPoint) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].position = newPosition
        }
    }

    func updateImageScale(id: Int64, newScale: CGFloat) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].scale = newScale
        }
    }

    func updateImageRotation(id: Int64, newRotation: Double) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].rotation = newRotation
        }
    }

    func selectImage(id: Int64?) {
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
            // ✅ UseCase를 통해 이미지 업로드
            let uploadedURL = try await productUseCase.execute(jpgData: jpgData)
            self.capturedImageString = uploadedURL
            
            print("✅ 최종 이미지 URL 저장 완료")
        } catch {
            print("❌ 이미지 업로드 실패: \(error.localizedDescription)")
        }
    }
    
    private func setupEditDataSubscription() {
        AddCodiViewModel.editCodiRequested
            .compactMap { $0 } // nil이 아닌 경우만 처리
            .receive(on: DispatchQueue.main)
            .sink { [weak self] editData in
                guard let self = self else { return }
                
                // 1. 이미 상품 목록이 로드된 경우 즉시 복원
                if !self.clothItems.isEmpty {
                    self.restoreCodiData(from: editData)
                } else {
                    // 2. 아직 로드 전이면 보관해두었다가 didSet에서 실행
                    self.pendingEditData = editData
                    print("--- ⏳ 상품 목록 대기 중 (ID: \(editData.payloads.count)개) ---")
                }
            }
            .store(in: &cancellables)
    }
    
    private func restoreCodiData(from editData: CodiEditData) {
        print("--- 📥 데이터 복원 시작 (전달된 페이로드: \(editData.payloads.count)개) ---")
        
        // 1. 체크 표시용 ID 세트 업데이트
        // Int64 -> Int 변환 시 발생할 수 있는 잠재적 문제를 방지하기 위해 compactMap 사용
        let clothIds = editData.payloads.map { Int($0.clothId) }
        self.selectedProductIds = Set(clothIds)
        
        // 2. 이미지 엔티티 복원
        self.images = editData.payloads.compactMap { payload in
            let actualX = (payload.locationX * boardSize) - (boardSize / 2)
            let actualY = (payload.locationY * boardSize) - (boardSize / 2)
            
            // ✅ [수정] Int64로 타입을 확장하여 비교 (가장 안전함)
            guard let item = clothItems.first(where: { Int64($0.id) == payload.clothId }) else {
                print("⚠️ 복원 실패: clothId \(payload.clothId)가 현재 로드된 clothItems에 없습니다.")
                // 만약 여기서 nil이 반환되면 캔버스에 이미지가 그려지지 않습니다.
                return nil
            }
            
            print("✅ 상품 매칭 성공: \(item.name ?? "이름없음") (ID: \(payload.clothId))")
            
            return DraggableImageEntity(
                id: payload.clothId,
                name: item.imageUrl ?? item.imageName ?? "",
                position: CGPoint(x: actualX, y: actualY),
                scale: CGFloat(payload.ratio),
                rotation: payload.degree
            )
        }
        
        print("✅ 복원 완료: 총 \(images.count)개의 이미지가 생성됨")
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
            imageString: imageURL
        )
        
        Self.codiDataUpdated.send(dataToTransfer)
        
        print("--- 🚀 AddCodiView로 데이터 전송 완료 ---")
        print("📍 Image URL: \(imageURL)")
        print("📍 Payloads 개수: \(finalData.count)")
        
        navigationRouter.navigateBack()
    }
}
