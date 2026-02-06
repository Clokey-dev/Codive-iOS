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
    @Published var selectedImageID: Int?
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
        
        setupCodiDataSubscription()
    }
    
    // MARK: - Private Methods
    
    /// 초기 코디판 이미지 데이터를 로드
    private func setupCodiDataSubscription() {
        HomeViewModel.codiTransferPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transferredData in
                guard let self = self else { return }
                
                self.images = transferredData.images
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation
    
    /// 이전 화면으로 이동
    func handleBackTap() {
        if homeViewModel?.todayCodiPreview != nil {
                    homeViewModel?.hasCodi = true
                }
        navigationRouter.navigateBack()
    }
    
    // MARK: - Actions
    
    /// 구성된 코디를 서버에 저장하고 홈 화면의 완료 팝업을 띄움
    func handleConfirmCodi() {
        Task {
            let actualSize = boardSize
            let centerOffset = actualSize / 2
            
            let captureView = ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.Codive.grayscale7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.Codive.grayscale5, lineWidth: 1)
                    )
                
                DraggableImageView(items: .constant(images)) { _ in }
            }
                .frame(width: actualSize, height: actualSize)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            let renderer = ImageRenderer(content: captureView)
            renderer.scale = UIScreen.main.scale
            
            guard var uiImage = renderer.uiImage else { return }
            
            let targetSize = CGSize(width: 260, height: 260)
            uiImage = resizeImage(image: uiImage, targetSize: targetSize)
            
            guard let jpgData = uiImage.jpegData(compressionQuality: 0.8) else { return }
            
            do {
                let uploadedURL = try await todayCodiUseCase.execute(jpgData: jpgData)
                
                let finalPayloads = images.enumerated().map { index, entity in
                    let absoluteX = max(0, min(actualSize, entity.position.x + centerOffset))
                    let absoluteY = max(0, min(actualSize, entity.position.y + centerOffset))
                    
                    let positiveDegree = entity.rotation < 0 ? entity.rotation + 360 : entity.rotation
                    
                    return Payloads(
                        clothId: entity.id,
                        locationX: Double(absoluteX / actualSize),
                        locationY: Double(absoluteY / actualSize),
                        ratio: Double(entity.scale),
                        degree: positiveDegree,
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
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    private func handleError(_ error: Error) {
        print("코디 저장 실패: \(error.localizedDescription)")
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
