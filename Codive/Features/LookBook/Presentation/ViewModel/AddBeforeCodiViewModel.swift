//
//  AddBeforeCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

@MainActor
final class AddBeforeCodiViewModel: ObservableObject {
    // MARK: - Properties
    let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    let lookbookId: Int
    
    @Published var lookBookList: [BeforeCodiEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var selectedLookBookIds: Set<Int> = []
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase, lookbookId: Int) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.lookbookId = lookbookId
    }
    
    func fetchLookBooks() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let list = try await useCase.fetchBeforeCodiList()
                self.lookBookList = list
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func toggleSelection(id: Int) {
        // 단일 선택으로 변경하고 바로 AddCodiView로 이동
        if let selectedCodi = lookBookList.first(where: { $0.id == id }) {
            navigateToAddCodiWithData(codi: selectedCodi)
        }
    }

    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func navigateToAddCodiWithData(codi: BeforeCodiEntity) {
        // AddCodiView로 이동하면서 선택한 코디 데이터 전달
        let selectedData = SelectedCodi(
            codiId: 0, imageURL: codi.imageURL,
            name: codi.name,
            memo: codi.memo
        )
        navigationRouter.navigate(to: .addCodi(
            lookbookId: lookbookId,
            selectedCodiData: selectedData
        ))
    }
    
    func navigateToSpecificLookBook(id: Int) {
        navigationRouter.navigate(to: .specificLookbook(lookbookId: id))
    }
}

extension AddBeforeCodiViewModel {
    static var preview: AddBeforeCodiViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = LookBookDataSource()
        let mockRepository = LookBookRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = LookBookUseCase(repository: mockRepository)
        return AddBeforeCodiViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase,
            lookbookId: 1
        )
    }
}
