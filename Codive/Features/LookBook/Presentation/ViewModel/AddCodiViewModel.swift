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
    
    // MARK: - Published Properties (View Bindings)
    @Published var codiName: String = ""
    @Published var memo: String = ""
    
    // MARK: - Computed Properties (Button Activation)
    var isButtonEnabled: Bool {
        !codiName.isEmpty
    }
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Actions
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func handleCodiUploadTap() {
        print("코디 업로드 버튼 클릭")
    }
    
    func handleCompleteTap() {
        print("코디 등록 완료. 닉네임: \(codiName), 메모: \(memo)")
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
            useCase: mockUseCase
        )
    }
}
