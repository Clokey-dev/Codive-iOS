//
//  EditCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

@MainActor
final class EditCodiViewModel: ObservableObject {
    
    // MARK: - Properties (State: Editable)
    
    @Published var codiName: String = ""
    @Published var memo: String = ""
    @Published var selectedImageURL: String?
    
    private var payloads: [Payloads] = []
    
    // MARK: - Properties (Internal State)
    
    /// 변경 사항 감지를 위한 초기 데이터 백업
    private var originalName: String = ""
    private var originalMemo: String = ""
    
    // MARK: - Properties (Dependencies)
    
    private let navigationRouter: NavigationRouter
    private let coordinateId: Int64?
    
    // MARK: - Computed Properties
    
    /// 초기값과 비교하여 텍스트 데이터에 변경이 있는지 확인합니다.
    var hasChanges: Bool {
        return codiName != originalName || memo != originalMemo
    }
    
    /// 완료 버튼 활성화 여부 (이름이 비어있지 않고, 변경 사항이 있을 때)
    var isButtonEnabled: Bool {
        return !codiName.isEmpty && hasChanges
    }
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        selectedCodiData: SelectedCodi? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.coordinateId = selectedCodiData?.coordinateId
        
        // 전달받은 초기 데이터 설정
        if let data = selectedCodiData {
            self.selectedImageURL = data.imageUrl
            self.codiName = data.name
            self.memo = data.memo
            self.originalName = data.name
            self.originalMemo = data.memo
            self.payloads = data.payloads ?? []
        }
    }
}

// MARK: - User Actions

extension EditCodiViewModel {
    
    /// 이전 화면으로 이동합니다.
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    /// 수정 사항을 반영하고 저장 로직을 실행합니다.
    func handleCompleteTap() {
        guard hasChanges else { return }
        
        // TODO: 서버 API 호출을 통한 수정 로직 반영 필요
        // try await codiUseCase.updateCodi(id: codiId, name: codiName, memo: memo)
        
        navigationRouter.navigateBack()
    }
    
    func handleOverlayTap() {
        guard let imageURL = selectedImageURL else {
            print("⚠️ 편집할 이미지가 없습니다.")
            return
        }

        let editData = CodiEditData(
            payloads: self.payloads,
            imageURL: imageURL,
            codiName: self.codiName,
            memo: self.memo
        )
        
        print("--- 📤 EditCodi -> AddCodiDetail 데이터 전송 ---")
        
        self.payloads.forEach { payload in
            print("📍 전송되는 Payload clothId: \(payload.clothId)")
        }
        
        AddCodiViewModel.editCodiRequested.value = editData
        
        navigationRouter.navigate(to: .addCodiDetail)
    }
}

// MARK: - Private Helpers

//private extension EditCodiViewModel {
//
//    /// (필요 시) 서버 연동 실패 등 에러 발생 시 처리 로직
//    func handleError(_ error: Error) {
//        print("DEBUG: 코디 수정 실패 - \(error.localizedDescription)")
//    }
//}
