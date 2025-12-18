//
//  EditCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

@MainActor
final class EditCodiViewModel: ObservableObject {
    private let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    let lookbookId: Int
    let codiId: Int?
    
    // 원본 데이터 저장 (수정 여부 비교용)
    private var originalName: String = ""
    private var originalMemo: String = ""
    
    @Published var codiName: String = ""
    @Published var memo: String = ""
    @Published var selectedImageURL: String? = nil
    
    // 수정 사항이 있는지 여부 확인
    var hasChanges: Bool {
        return codiName != originalName || memo != originalMemo
    }
    
    var isButtonEnabled: Bool {
        !codiName.isEmpty && hasChanges
    }
    
    init(
        navigationRouter: NavigationRouter,
        useCase: LookBookUseCase,
        lookbookId: Int,
        selectedCodiData: SelectedCodi? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.lookbookId = lookbookId
        self.codiId = selectedCodiData?.codiId
        
        if let data = selectedCodiData {
            self.selectedImageURL = data.imageURL
            self.codiName = data.name
            self.memo = data.memo
            
            // 비교를 위한 원본 값 저장
            self.originalName = data.name
            self.originalMemo = data.memo
        }
    }
    
    func handleBackTap() { navigationRouter.navigateBack() }
    
    func handleCompleteTap() {
        guard hasChanges else { return }
        print("수정 완료 제출: \(codiName)")
    }
}

extension EditCodiViewModel {
    static var preview: EditCodiViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = LookBookDataSource()
        let mockRepository = LookBookRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = LookBookUseCase(repository: mockRepository)
        return EditCodiViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase,
            lookbookId: 1
        )
    }
}
