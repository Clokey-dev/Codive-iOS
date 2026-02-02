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
    
    private var cancellables = Set<AnyCancellable>() // ✅ 추가
    
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "전체"
    @Published var selectedProductIds: Set<Int> = []
//    @Published var clothItems: [ProductItem] = []
    @Published var clothItems: [ProductItem] = [] {
        didSet {
            // ✅ 상품 리스트가 로드되면 보관해둔 편집 데이터가 있는지 확인하고 복원 진행
            if !clothItems.isEmpty, let pendingData = pendingEditData {
                restoreCodiData(from: pendingData)
                self.pendingEditData = nil // 복원 후 초기화
            }
        }
    }
    // 복원 대기 중인 데이터를 담을 변수
    private var pendingEditData: CodiEditData?
    
    @Published var images: [DraggableImageEntity] = []
    @Published var currentlyDraggedID: Int?
    @Published var selectedImageID: Int?
    @Published var capturedImageString: String? = nil
    var boardSize: CGFloat = 300
    
    private let navigationRouter: NavigationRouter
    private let productUseCase: ProductUseCase
    private let lookbookId: Int64
    
    // AddCodiDetailViewModel.swift

    var codiPayloads: [Payloads] {
        return images.enumerated().map { (index, entity) in
            // 보드 중앙 기준 좌표를 0.0 ~ 1.0 비율로 변환
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
                degree: positiveDegree, // 정규화된 양수값 전달
                order: Int32(index + 1)
            )
        }
    }
    
    init(navigationRouter: NavigationRouter, productUseCase: ProductUseCase, lookbookId: Int64) {
        self.navigationRouter = navigationRouter
        self.productUseCase = productUseCase
        self.lookbookId = lookbookId
        
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
            images.removeAll { $0.id == product.id }
        } else if selectedProductIds.count < 10 {
            selectedProductIds.insert(product.id)
            
            // 신규 이미지 추가 시 중앙 좌표 근처로 설정
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
    
    private func removeImage(productId: Int) {
        images.removeAll { $0.id == productId }
        if selectedImageID == productId { selectedImageID = nil }
    }
    
    // 제스처 결과 반영 메서드들
    func bringImageToFront(id: Int64) {
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
            // ✅ UseCase를 통해 이미지 업로드
            let uploadedURL = try await productUseCase.execute(jpgData: jpgData)
            self.capturedImageString = uploadedURL
            
            print("✅ 최종 이미지 URL 저장 완료")
        } catch {
            print("❌ 이미지 업로드 실패: \(error.localizedDescription)")
        }
    }
    
//    private func setupEditDataSubscription() {
//        AddCodiViewModel.editCodiRequested
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] editData in
//                self?.restoreCodiData(from: editData)
//            }
//            .store(in: &cancellables)
//    }
    private func setupEditDataSubscription() {
        AddCodiViewModel.editCodiRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] editData in
                // ✅ 상품 리스트가 이미 있다면 즉시 복원, 없다면 대기
                if let self = self {
                    if self.clothItems.isEmpty {
                        self.pendingEditData = editData
                        print("--- ⏳ 상품 리스트 로딩 대기 중... ---")
                    } else {
                        self.restoreCodiData(from: editData)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // ✅ 새로운 메서드: 코디 데이터 복원
    private func restoreCodiData(from editData: CodiEditData) {
        print("--- 📥 편집 데이터 수신 완료 ---")
        print("📍 복원할 Payloads 개수: \(editData.payloads.count)")
        
        // 기존 이미지 URL 저장 (나중에 참고용으로 사용 가능)
        self.capturedImageString = editData.imageURL
        
        // ✅ 먼저 selectedProductIds를 복원 (CustomProductBottomSheet에서 체크 표시를 위해)
        let clothIds = editData.payloads.map { Int($0.clothId) }
        self.selectedProductIds = Set(clothIds)
        
        print("📍 복원할 clothId 목록: \(clothIds)")
        print("📍 현재 로드된 clothItems 개수: \(clothItems.count)")
        
        // Payloads를 DraggableImageEntity로 변환
        self.images = editData.payloads.compactMap { payload in
            // 정규화된 좌표(0.0~1.0)를 실제 위치로 역변환
            let actualX = (payload.locationX * boardSize) - (boardSize / 2)
            let actualY = (payload.locationY * boardSize) - (boardSize / 2)
            
            // 해당 clothId의 이미지 URL 찾기
            guard let clothItem = clothItems.first(where: { $0.id == Int(payload.clothId) }) else {
                print("⚠️ clothId \(payload.clothId)에 해당하는 상품을 찾을 수 없습니다.")
                return nil
            }
            
            let imageURL = clothItem.imageUrl ?? clothItem.imageName ?? ""
            
            print("""
                [복원 #\(payload.order)]
                - clothId: \(payload.clothId)
                - imageName: \(clothItem.name ?? "unknown")
                - imageURL: \(imageURL)
                - 정규화 좌표: (\(payload.locationX), \(payload.locationY))
                - 실제 위치: (\(actualX), \(actualY))
                - scale: \(payload.ratio)
                - rotation: \(payload.degree)
                """)
            
            return DraggableImageEntity(
                id: payload.clothId,
                name: imageURL,
                position: CGPoint(x: actualX, y: actualY),
                scale: CGFloat(payload.ratio),
                rotation: payload.degree
            )
        }
        
        print("✅ 코디 데이터 복원 완료")
        print("📍 복원된 이미지 개수: \(images.count)")
        print("📍 선택된 상품 ID: \(selectedProductIds)")
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
