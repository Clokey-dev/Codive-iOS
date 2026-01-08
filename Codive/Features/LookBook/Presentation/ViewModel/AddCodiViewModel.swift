//
//  AddCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI

@MainActor
final class AddCodiViewModel: ObservableObject {
    
    // MARK: - Dependencies
    
    private let navigationRouter: NavigationRouter
    let coordinateId: Int
    
    // MARK: - Published State (Codi Info)
    
    @Published var codiName: String = ""
    @Published var memo: String = ""
    @Published var selectedImageURL: String?
    
    // MARK: - Published State (UI Control)
    
    @Published var isNewlyCombined: Bool = false
    @Published var isShowingBottomSheet: Bool = false
    @Published var isShowingSuccessView: Bool = false
    @Published var successMessage: String = ""
    
    // MARK: - Published State (Combined Items)
    
    @Published var combinedItems: [DraggableImageEntity] = []
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        coordinateId: Int,
    ) {
        self.navigationRouter = navigationRouter
        self.coordinateId = coordinateId
    }
    
    // MARK: - Computed Properties
    
    var isButtonEnabled: Bool {
        let hasImage =
        (selectedImageURL != nil && !(selectedImageURL?.isEmpty ?? true)) ||
        !combinedItems.isEmpty
        
        return !codiName.isEmpty && hasImage
    }
    
    // MARK: - User Actions
    
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func handleCodiUploadTap() {
        isShowingBottomSheet = true
    }
    
    func handleCompleteTap() {
        isShowingSuccessView = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isShowingSuccessView = false
            self.navigationRouter.navigateBack()
        }
    }
    
    // MARK: - Navigation (Bottom Sheet Actions)
    
    func navigateToNewCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addCodiDetail(lookbookId: coordinateId))
    }
    
    func handleRecallCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addBeforeCodi(lookbookId: coordinateId))
    }
}
