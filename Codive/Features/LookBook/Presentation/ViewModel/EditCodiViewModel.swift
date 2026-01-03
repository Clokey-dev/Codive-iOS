//
//  EditCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

@MainActor
final class EditCodiViewModel: ObservableObject {
    
    // MARK: - Dependencies
    
    private let navigationRouter: NavigationRouter
    let lookbookId: Int
    let codiId: Int?
    
    // MARK: - Original Data (Change Detection)
    
    private var originalName: String = ""
    private var originalMemo: String = ""
    
    // MARK: - Published State (Editable Fields)
    
    @Published var codiName: String = ""
    @Published var memo: String = ""
    @Published var selectedImageURL: String?
    
    // MARK: - Computed Properties
    
    var hasChanges: Bool {
        return codiName != originalName || memo != originalMemo
    }
    
    var isButtonEnabled: Bool {
        !codiName.isEmpty && hasChanges
    }
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        lookbookId: Int,
        selectedCodiData: SelectedCodi? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.lookbookId = lookbookId
        self.codiId = selectedCodiData?.codiId
        
        if let data = selectedCodiData {
            self.selectedImageURL = data.imageURL
            self.codiName = data.name
            self.memo = data.memo
            self.originalName = data.name
            self.originalMemo = data.memo
        }
    }
    
    // MARK: - User Actions
    
    /// 상단 백 버튼 탭 처리
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func handleCompleteTap() {
        guard hasChanges else { return }
        navigationRouter.navigateBack()
    }
}
