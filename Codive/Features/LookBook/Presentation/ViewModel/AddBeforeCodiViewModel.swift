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
    
    @Published var lookBookList: [BeforeCodiEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var selectedLookBookIds: Set<Int> = []
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
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
        if selectedLookBookIds.contains(id) {
            selectedLookBookIds.remove(id)
        } else {
            selectedLookBookIds.insert(id)
        }
    }

    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
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
            useCase: mockUseCase
        )
    }
}
