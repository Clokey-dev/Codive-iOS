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
    
    @Published var codiName: String = ""
    @Published var memo: String = ""
    @Published var isNavEditingMode: Bool = false
    @Published var selectedImageURL: String?
    @Published var isLayoutChanged: Bool = false
    
    private var payloads: [Payloads] = []
    private var originalName: String = ""
    private var originalMemo: String = ""
    
    private let navigationRouter: NavigationRouter
    private let codiUseCase: CodiUseCase
    private let coordinateId: Int64?
    
    var hasChanges: Bool {
        let isTextChanged = (codiName != originalName || memo != originalMemo)
        return isTextChanged || isLayoutChanged
    }
    
    var isButtonEnabled: Bool {
        return !codiName.isEmpty && hasChanges
    }
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        codiUseCase: CodiUseCase,
        selectedCodiData: SelectedCodi? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.codiUseCase = codiUseCase
        self.coordinateId = selectedCodiData?.coordinateId
        
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
    private func setupCodiDataSubscription() {
        AddCodiDetailViewModel.codiDataUpdated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedData in
                guard let self = self else { return }
                
                self.selectedImageURL = updatedData.imageString
                self.payloads = updatedData.payloads
                self.isLayoutChanged = true
            }
            .store(in: &cancellables)
    }
}

// MARK: - User Actions

extension EditCodiViewModel {
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func handleCompleteTap() {
        guard let coordinateId = coordinateId, isButtonEnabled else { return }
        
        Task {
            do {
                let request = EditCoordinateRequestDTO(
                    coordinateImageUrl: selectedImageURL,
                    name: codiName,
                    memo: memo,
                    payloads: payloads
                )
                
                try await codiUseCase.patchUpdateCoordinates(
                    coordinateId: coordinateId,
                    request: request
                )
                
                #if DEBUG
                print("[Codi] 수정 완료: \(coordinateId)")
                #endif
                
                self.originalName = codiName
                self.originalMemo = memo
                self.isLayoutChanged = false
                
                navigationRouter.navigateBack()
            } catch {
                #if DEBUG
                print("[Codi] 수정 실패: \(error.localizedDescription)")
                #endif
            }
        }
    }
    
    func handleOverlayTap() {
        guard let imageURL = selectedImageURL else {
            return
        }
        
        let editData = CodiEditData(
            payloads: self.payloads,
            imageURL: imageURL,
            codiName: self.codiName,
            memo: self.memo
        )
        
        AddCodiViewModel.editCodiRequested.value = editData
        
        navigationRouter.navigate(to: .addCodiDetail)
    }
}

extension EditCodiViewModel {
    
    func startNavEditing() {
        isNavEditingMode = true
    }
    
    func finishNavEditing() {
        isNavEditingMode = false
    }
}
