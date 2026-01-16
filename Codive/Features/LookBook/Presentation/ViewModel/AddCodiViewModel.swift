//
//  AddCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI

@MainActor
final class AddCodiViewModel: ObservableObject {
    
    // MARK: - Properties (State)
    
    @Published var codiName: String = ""
    @Published var memo: String = ""
    @Published var selectedImageURL: String?
    
    /// 새로 조합된 아이템 리스트
    @Published var combinedItems: [DraggableImageEntity] = []
    
    // UI 제어 상태
    @Published var isNewlyCombined: Bool = false
    @Published var isShowingBottomSheet: Bool = false
    @Published var isShowingSuccessView: Bool = false
    @Published var successMessage: String = ""
    
    // MARK: - Properties (Dependencies)
    
    private let navigationRouter: NavigationRouter
    let coordinateId: Int
    
    // MARK: - Computed Properties
    
    /// 등록 버튼 활성화 여부 (이름이 있고, 선택된 이미지나 조합된 아이템이 있을 때)
    var isButtonEnabled: Bool {
        let hasImage = (selectedImageURL != nil && !(selectedImageURL?.isEmpty ?? true)) || !combinedItems.isEmpty
        return !codiName.isEmpty && hasImage
    }
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        coordinateId: Int
    ) {
        self.navigationRouter = navigationRouter
        self.coordinateId = coordinateId
    }
}

// MARK: - User Actions

extension AddCodiViewModel {
    
    /// 이전 화면으로 이동합니다.
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    /// 코디 업로드 버튼 탭 시 바텀시트를 표시합니다.
    func handleCodiUploadTap() {
        isShowingBottomSheet = true
    }
    
    /// 코디 등록을 완료합니다. (성공 팝업 표시 후 화면 이동)
    func handleCompleteTap() {
        isShowingSuccessView = true
        
        // TODO: 실제 서버 저장 로직 추가 필요
        
        // 성공 메시지 표시 후 1.5초 뒤 메인으로 복귀
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isShowingSuccessView = false
            self?.navigationRouter.navigateBack()
        }
    }
}

// MARK: - Navigation (Bottom Sheet Actions)

extension AddCodiViewModel {
    
    /// '새로 만들기' 선택 시 코디 상세 편집 화면으로 이동합니다.
    func navigateToNewCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addCodiDetail(lookbookId: coordinateId))
    }
    
    /// '이전 코디 불러오기' 선택 시 기록 화면으로 이동합니다.
    func handleRecallCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addBeforeCodi(lookbookId: coordinateId))
    }
}
