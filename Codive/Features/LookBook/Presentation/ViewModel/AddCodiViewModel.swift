//
//  AddCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI
import Combine

@MainActor
final class AddCodiViewModel: ObservableObject {
    
    // MARK: - Properties (State)
    @Published var codiName: String = ""
    @Published var memo: String = ""
    
    // 초기 상태는 모두 nil/비어있음으로 설정하여 플레이스홀더가 나오게 함
    @Published var selectedImageURL: String? = nil
    @Published var capturedImage: UIImage? = nil
    @Published var combinedItems: [DraggableImageEntity] = []
    
    // 서버 전송용 데이터
    @Published var receivedPayloads: [Payloads] = []
    
    // UI 제어 상태
    @Published var isNewlyCombined: Bool = false
    @Published var isShowingBottomSheet: Bool = false
    @Published var isShowingSuccessView: Bool = false
    @Published var successMessage: String = ""
    
    // MARK: - Dependencies
    private var cancellables = Set<AnyCancellable>()
    private let navigationRouter: NavigationRouter
    let coordinateId: Int
    
    // MARK: - Computed Properties
    var isButtonEnabled: Bool {
        // 이미지가 있거나 캡처본이 있고, 이름이 입력되었을 때 활성화
        let hasImage = (selectedImageURL != nil && !selectedImageURL!.isEmpty) || capturedImage != nil || !combinedItems.isEmpty
        return !codiName.isEmpty && hasImage
    }
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, coordinateId: Int) {
        self.navigationRouter = navigationRouter
        self.coordinateId = coordinateId
        
        // 데이터 수신 구독 설정
        setupDataSubscription()
    }
}

// MARK: - Setup Subscription
private extension AddCodiViewModel {
    func setupDataSubscription() {
        cancellables.removeAll() // 중복 구독 방지

        AddCodiDetailViewModel.codiDataUpdated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                print("--- 📥 AddCodiDetail로부터 데이터 수신 성공 ---")
                self?.receivedPayloads = data.payloads
                
                // Base64 문자열을 UIImage로 변환하여 저장
                if let imageData = Data(base64Encoded: data.imageString),
                   let uiImage = UIImage(data: imageData) {
                    self?.capturedImage = uiImage
                }
                
                self?.isNewlyCombined = true
            }
            .store(in: &cancellables)
    }
}

// MARK: - User Actions
extension AddCodiViewModel {
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func handleCodiUploadTap() {
        isShowingBottomSheet = true
    }
    
    func handleCompleteTap() {
        isShowingSuccessView = true
        // TODO: 실제 서버 저장 로직 (receivedPayloads, capturedImage 등 활용)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isShowingSuccessView = false
            self?.navigationRouter.navigateBack()
        }
    }
    
    func navigateToNewCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addCodiDetail(lookbookId: coordinateId))
    }
    
    func handleRecallCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addBeforeCodi(lookbookId: coordinateId))
    }
}
