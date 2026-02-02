//
//  EditCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI
import Combine

@MainActor
final class EditCodiViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties (State: Editable)
    
    @Published var codiName: String = ""
    @Published var memo: String = ""
    @Published var isNavEditingMode: Bool = false
    @Published var selectedImageURL: String?
    @Published var isLayoutChanged: Bool = false
    
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
        // 1. 텍스트 필드 변경 확인
        let isTextChanged = (codiName != originalName || memo != originalMemo)
        // 2. 텍스트 혹은 레이아웃(이미지 포함) 둘 중 하나라도 변하면 true
        return isTextChanged || isLayoutChanged
    }
    
    /// 완료 버튼 활성화 여부
    var isButtonEnabled: Bool {
        // 이름이 비어있지 않고, 어떠한 변경 사항이라도 있을 때 활성화
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
        
        setupCodiDataSubscription()
    }
}

extension EditCodiViewModel {
    /// AddCodiDetailView에서 변경되어 돌아오는 데이터를 감지합니다.
    private func setupCodiDataSubscription() {
        AddCodiDetailViewModel.codiDataUpdated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedData in
                guard let self = self else { return }
                
                self.selectedImageURL = updatedData.imageString
                self.payloads = updatedData.payloads
                
                // ✅ 이미지나 페이로드가 업데이트되었다면 변경됨으로 표시
                self.isLayoutChanged = true
                
                print("--- 📥 데이터 수신 및 변경 플래그 활성화 ---")
            }
            .store(in: &cancellables)
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

extension EditCodiViewModel {
    
    func startNavEditing() {
        isNavEditingMode = true
    }
    
    /// 네비게이션 바에서 편집 완료 (Return 키 등)
    func finishNavEditing() {
        isNavEditingMode = false
    }
}
