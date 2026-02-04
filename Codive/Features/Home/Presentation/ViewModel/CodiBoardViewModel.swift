//
//  CodiBoardViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI
import Combine

@MainActor
final class CodiBoardViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isConfirmed: Bool = false
    @Published var images: [DraggableImageEntity] = []
    private var cancellables = Set<AnyCancellable>()
    @Published var currentlyDraggedID: Int?
    @Published var selectedImageID: Int? // 추가된 속성
    @Published var boardSize: CGFloat = 260
    
    private let codiBoardUseCase: CodiBoardUseCase
    private let todayCodiUseCase: TodayCodiUseCase
    private let navigationRouter: NavigationRouter
    private weak var homeViewModel: HomeViewModel?
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        codiBoardUseCase: CodiBoardUseCase,
        todayCodiUseCase: TodayCodiUseCase,
        homeViewModel: HomeViewModel? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.codiBoardUseCase = codiBoardUseCase
        self.todayCodiUseCase = todayCodiUseCase
        self.homeViewModel = homeViewModel
        
//        loadInitialData()
        setupCodiDataSubscription()
    }
    
    // MARK: - Private Methods
    
    /// 초기 코디판 이미지 데이터를 로드
//    private func loadInitialData() {
//        self.images = codiBoardUseCase.loadCodiBoardImages()
//    }

    private func setupCodiDataSubscription() {
        HomeViewModel.codiTransferPublisher
            .compactMap { $0 } // nil이 아닌 데이터만 통과
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transferredData in
                guard let self = self else { return }
                
                print("""
                [받는 쪽: CodiBoardViewModel] ✅ 데이터 수신 성공!
                - 받은 아이템 개수: \(transferredData.images.count)개
                - 아이템 IDs: \(transferredData.images.map { $0.id })
                """)
                
                // 기존 images에 할당
                self.images = transferredData.images
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation
    
    /// 이전 화면으로 이동
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    // MARK: - Actions
    
    /// 구성된 코디를 서버에 저장하고 홈 화면의 완료 팝업을 띄움
//    func handleConfirmCodi() {
////        Task {
////            do {
////                // 1. 서버에 데이터 전송
////                try await codiBoardUseCase.saveCodiItems(images)
////                
////                // 2. 저장 성공 후 UI 처리 (MainActor에서 실행됨)
////                let imageURL = images.first?.imageURL
////                navigationRouter.navigateBack()
////                
////                // 홈 화면으로 돌아가는 애니메이션 시간을 고려하여 지연 실행
////                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
////                    self?.homeViewModel?.showCompletionPopup(imageURL: imageURL)
////                }
////                
////                self.isConfirmed = true
////            } catch {
////                handleError(error)
////            }
////        }
//    }
    // CodiBoardViewModel.swift

    // CodiBoardViewModel.swift

    // CodiBoardViewModel.swift 내 handleConfirmCodi 수정

//    func handleConfirmCodi() {
//        Task {
//            let boardSize: CGFloat = 260
//            let centerOffset = boardSize / 2
//            
//            // ✅ 수정 포인트: $images 대신 .constant(images)를 사용하여 Binding 타입으로 전달
//            let captureView = DraggableImageView(
//                items: .constant(images),
//                onActivate: { _ in }
//            )
//            .frame(width: boardSize, height: boardSize)
//            .background(Color.Codive.grayscale7)
//            
//            let renderer = ImageRenderer(content: captureView)
//            renderer.scale = UIScreen.main.scale
//            
//            guard let uiImage = renderer.uiImage,
//                  let jpgData = uiImage.jpegData(compressionQuality: 0.8) else { return }
//            
//            do {
//                // 이후 업로드 및 데이터 처리 로직 동일
//                let uploadedURL = try await todayCodiUseCase.execute(jpgData: jpgData)
//                
//                let finalPayloads = images.enumerated().map { index, entity in
//                    let absoluteX = entity.position.x + centerOffset
//                    let absoluteY = entity.position.y + centerOffset
//                    
//                    return Payloads(
//                        clothId: entity.id,
//                        locationX: Double(absoluteX / boardSize),
//                        locationY: Double(absoluteY / boardSize),
//                        ratio: Double(entity.scale),
//                        degree: entity.rotation,
//                        order: Int32(index + 1)
//                    )
//                }
//                
//                await MainActor.run {
//                    guard let homeVM = homeViewModel else { return }
//                    homeVM.capturedImageURL = uploadedURL
//                    homeVM.boardPayloads = finalPayloads
//                    homeVM.showCompletePopUp = true
//                    
//                    navigationRouter.navigateBack()
//                }
//            } catch {
//                print("❌ 저장 실패: \(error.localizedDescription)")
//            }
//        }
//    }
    func handleConfirmCodi() {
            Task {
                // ✅ 2. 실제 화면 크기를 기준으로 캡처를 진행합니다.
                let actualSize = boardSize
                let centerOffset = actualSize / 2
                
                print("📸 [Capture] 실제 보드 크기(\(actualSize))로 캡처 시작...")
                
                let captureView = ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.Codive.grayscale7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.Codive.grayscale5, lineWidth: 1)
                        )
                    
                    DraggableImageView(
                        items: .constant(images),
                        onActivate: { _ in }
                    )
                }
                .frame(width: actualSize, height: actualSize) // 실제 크기 적용
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                let renderer = ImageRenderer(content: captureView)
                renderer.scale = UIScreen.main.scale
                
                guard var uiImage = renderer.uiImage else { return }
                
                // ✅ 3. 캡처된 이미지를 260x260 사이즈로 리사이징합니다.
                let targetSize = CGSize(width: 260, height: 260)
                uiImage = resizeImage(image: uiImage, targetSize: targetSize)
                
                guard let jpgData = uiImage.jpegData(compressionQuality: 0.8) else { return }
                
                do {
                    let uploadedURL = try await todayCodiUseCase.execute(jpgData: jpgData)
                    
                    // ✅ 4. 좌표 계산 시에도 실제 크기(actualSize)를 기준으로 정규화(0~1)를 수행합니다.
                    let finalPayloads = images.enumerated().map { index, entity in
                        let absoluteX = entity.position.x + centerOffset
                        let absoluteY = entity.position.y + centerOffset
                        
                        return Payloads(
                            clothId: entity.id,
                            locationX: Double(absoluteX / actualSize), // 0.0 ~ 1.0 사이 값
                            locationY: Double(absoluteY / actualSize),
                            ratio: Double(entity.scale),
                            degree: entity.rotation,
                            order: Int32(index + 1)
                        )
                    }

                    await MainActor.run {
                        guard let homeVM = homeViewModel else { return }
                        homeVM.capturedImageURL = uploadedURL
                        homeVM.boardPayloads = finalPayloads
                        navigationRouter.navigateBack()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            homeVM.showCompletePopUp = true
                        }
                    }
                } catch {
                    print("❌ 에러: \(error.localizedDescription)")
                }
            }
        }
        
        // ✅ UIImage 리사이징 헬퍼 함수
        private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
    
    /// 에러 발생 시 처리 로직
    private func handleError(_ error: Error) {
        print("코디 저장 실패: \(error.localizedDescription)")
        // TODO: 필요한 경우 사용자에게 보여줄 에러 알럿 로직 추가
    }
    
    // MARK: - DraggableImageViewModelProtocol Implementation
    
    /// 특정 이미지를 레이어의 최상단으로 가져옴
    func bringImageToFront(id: Int) {
        guard let index = images.firstIndex(where: { $0.id == id }) else { return }
        let tappedImage = images.remove(at: index)
        images.append(tappedImage)
    }
    
    /// 이미지의 위치(Position)를 업데이트
    func updateImagePosition(id: Int, newPosition: CGPoint) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].position = newPosition
        }
    }
    
    /// 이미지의 크기(Scale)를 업데이트
    func updateImageScale(id: Int, newScale: CGFloat) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].scale = newScale
        }
    }
    
    /// 이미지의 회전 각도(Rotation)를 업데이트
    func updateImageRotation(id: Int, newRotation: Double) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].rotation = newRotation
        }
    }
    
    /// 이미지 선택/해제 (추가된 메서드)
    func selectImage(id: Int?) {
        selectedImageID = id
    }
}
