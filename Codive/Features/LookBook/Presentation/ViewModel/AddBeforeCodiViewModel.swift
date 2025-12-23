//
//  AddBeforeCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

@MainActor
final class AddBeforeCodiViewModel: ObservableObject {
    
    // MARK: - Dependencies
    
    let navigationRouter: NavigationRouter
    private let beforeCodiUseCase: BeforeCodiUseCase
    let lookbookId: Int
    
    // MARK: - Published State (UI State)
    
    @Published var lookBookList: [BeforeCodiEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedLookBookIds: Set<Int> = []
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        beforeCodiUseCase: BeforeCodiUseCase,
        lookbookId: Int
    ) {
        self.navigationRouter = navigationRouter
        self.beforeCodiUseCase = beforeCodiUseCase
        self.lookbookId = lookbookId
    }
    
    // MARK: - Data Fetching
    
    func fetchLookBooks() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let list = try await beforeCodiUseCase.fetchBeforeCodiList()
                self.lookBookList = list
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // MARK: - Selection Logic
    
    func toggleSelection(id: Int) {
        if let selectedCodi = lookBookList.first(where: { $0.id == id }) {
            navigateToAddCodiWithData(codi: selectedCodi)
        }
    }
    
    // MARK: - Navigation
    
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func navigateToAddCodiWithData(codi: BeforeCodiEntity) {
        let selectedData = SelectedCodi(
            codiId: codi.id,
            imageURL: codi.imageURL,
            name: codi.name,
            memo: codi.memo
        )
        
        navigationRouter.navigate(
            to: .addCodi(
                lookbookId: lookbookId,
                selectedCodiData: selectedData
            )
        )
    }
    
    func navigateToSpecificLookBook(id: Int) {
        navigationRouter.navigate(to: .specificLookbook(lookbookId: id))
    }
}
