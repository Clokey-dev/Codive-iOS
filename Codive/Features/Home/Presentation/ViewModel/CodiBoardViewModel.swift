//
//  CodiBoardViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

@MainActor
final class CodiBoardViewModel: ObservableObject, DraggableImageViewModelProtocol {
    
    // MARK: - Properties
    
    @Published var isConfirmed: Bool = false
    @Published var images: [DraggableImageEntity] = []
    @Published var currentlyDraggedID: Int?
    
    private let codiBoardUseCase: CodiBoardUseCase
    private let navigationRouter: NavigationRouter
    private weak var homeViewModel: HomeViewModel?
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        codiBoardUseCase: CodiBoardUseCase,
        homeViewModel: HomeViewModel? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.codiBoardUseCase = codiBoardUseCase
        self.homeViewModel = homeViewModel
        
        loadInitialData()
    }
    
    // MARK: - Private Methods
    
    /// 초기 코디판 이미지 데이터를 로드
    private func loadInitialData() {
        self.images = codiBoardUseCase.loadCodiBoardImages()
    }
    
    // MARK: - Navigation
    
    /// 이전 화면으로 이동
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    // MARK: - Actions
    
    /// 구성된 코디를 서버에 저장하고 홈 화면의 완료 팝업을 띄움
    func handleConfirmCodi() {
        Task {
            do {
                // 1. 서버에 데이터 전송
                try await codiBoardUseCase.saveCodiItems(images)
                
                // 2. 저장 성공 후 UI 처리 (MainActor에서 실행됨)
                let imageURL = images.first?.imageURL
                navigationRouter.navigateBack()
                
                // 홈 화면으로 돌아가는 애니메이션 시간을 고려하여 지연 실행
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.homeViewModel?.showCompletionPopup(imageURL: imageURL)
                }
                
                self.isConfirmed = true
            } catch {
                handleError(error)
            }
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
            images[index].rotationAngle = newRotation
        }
    }
}
