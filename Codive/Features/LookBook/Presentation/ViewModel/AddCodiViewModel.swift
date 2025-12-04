//
//  AddCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI

@MainActor
final class AddCodiViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    let lookbookId: Int
    
    // MARK: - Published Properties (View Bindings)
    @Published var codiName: String = ""
    @Published var memo: String = ""
    
    // MARK: - UI State
    @Published var isShowingBottomSheet: Bool = false
    
    // MARK: - Computed Properties (Button Activation)
    var isButtonEnabled: Bool {
        !codiName.isEmpty
    }
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase, lookbookId: Int) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.lookbookId = lookbookId
    }
    
    // MARK: - Actions
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func handleCodiUploadTap() {
        isShowingBottomSheet = true
    }
    
    func handleCompleteTap() {
        print("코디 등록 완료. 닉네임: \(codiName), 메모: \(memo)")
    }

    func navigateToNewCodi() {
        isShowingBottomSheet = false
//        navigationRouter.navigate(to: .recordAdd)
    }

    func handleRecallCodi() {
        isShowingBottomSheet = false
        print("이전 코디 불러오기 tapped")
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
