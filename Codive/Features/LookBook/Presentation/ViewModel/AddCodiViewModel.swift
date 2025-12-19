//
//  AddCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI

@MainActor
final class AddCodiViewModel: ObservableObject {
    private let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    let lookbookId: Int
    
    @Published var codiName: String = ""
    @Published var memo: String = ""
    @Published var selectedImageURL: String? = nil
    
    @Published var isNewlyCombined: Bool = false
    @Published var isShowingBottomSheet: Bool = false
    
    // 성공 뷰 관련 상태 추가
    @Published var isShowingSuccessView: Bool = false
    @Published var successMessage: String = ""
    
    @Published var combinedItems: [DraggableImageEntity] = []

    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase, lookbookId: Int, selectedCodiData: SelectedCodi? = nil) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.lookbookId = lookbookId
        
        if let data = selectedCodiData {
            self.selectedImageURL = data.imageURL
            self.codiName = data.name
            self.memo = data.memo
            self.combinedItems = data.combinedItems ?? []
            self.isNewlyCombined = true
            
            // 진입 경로에 따른 메시지 설정
            if !self.combinedItems.isEmpty {
                // 직접 조합해서 온 경우 (AddCodiDetailView)
                self.successMessage = "옷코디를 완성했어요!"
            } else {
                // 이전 코디를 불러온 경우 (AddBeforeCodiView)
                self.successMessage = "코디를 추가했어요!"
            }
        }
    }
        
    var isButtonEnabled: Bool {
        let hasImage = (selectedImageURL != nil && !selectedImageURL!.isEmpty) || !combinedItems.isEmpty
        return !codiName.isEmpty && hasImage
    }
    
    func handleBackTap() { navigationRouter.navigateBack() }
    
    func handleCodiUploadTap() { isShowingBottomSheet = true }
    
    func handleCompleteTap() {
        // 성공 화면 표시
        isShowingSuccessView = true
        
        // 1.5초 후 화면 닫기 및 뒤로가기 동작 수행
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isShowingSuccessView = false
            self.navigationRouter.navigateBack()
        }
    }

    func navigateToNewCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addCodiDetail)
    }

    func handleRecallCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addBeforeCodi(lookbookId: lookbookId))
    }
}

extension AddCodiViewModel {
    static var preview: AddCodiViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = LookBookDataSource()
        let mockRepository = LookBookRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = LookBookUseCase(repository: mockRepository)
        return AddCodiViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase,
            lookbookId: 1
        )
    }
}
