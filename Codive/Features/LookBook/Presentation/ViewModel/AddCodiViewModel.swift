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
    
    // 추가: 이미지가 '방금 조합된 것'인지 확인하여 오버레이 표시 여부 결정
    @Published var isNewlyCombined: Bool = false
    @Published var isShowingBottomSheet: Bool = false
    
    @Published var combinedItems: [DraggableImageEntity] = []

        init(navigationRouter: NavigationRouter, useCase: LookBookUseCase, lookbookId: Int, selectedCodiData: SelectedCodi? = nil) {
            self.navigationRouter = navigationRouter
            self.useCase = useCase
            self.lookbookId = lookbookId
            
            if let data = selectedCodiData {
                self.selectedImageURL = data.imageURL
                self.codiName = data.name
                self.memo = data.memo
                // 리스트가 있으면 주입
                self.combinedItems = data.combinedItems ?? []
                self.isNewlyCombined = true
            }
        }
        
    // 버튼 활성화 조건: 이름이 있고, (단일 이미지나 조합된 아이템 중 하나라도 존재)
    var isButtonEnabled: Bool {
        let hasImage = (selectedImageURL != nil && !selectedImageURL!.isEmpty) || !combinedItems.isEmpty
        return !codiName.isEmpty && hasImage
    }
    
    func handleBackTap() { navigationRouter.navigateBack() }
    
    func handleCodiUploadTap() { isShowingBottomSheet = true }
    
    func handleCompleteTap() {
        print("최종 등록 완료: \(codiName)")
        // TODO: useCase.saveCodi(...)
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
