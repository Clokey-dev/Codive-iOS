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
    let coordinateId: Int
    
    // MARK: - Published State (UI State)
    
    @Published var beforeCoordinateDailyList: [BeforeCoordinateDailyEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedLookBookIds: Set<Int> = []
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        beforeCodiUseCase: BeforeCodiUseCase,
        coordinateId: Int
    ) {
        self.navigationRouter = navigationRouter
        self.beforeCodiUseCase = beforeCodiUseCase
        self.coordinateId = coordinateId
    }
    
    // MARK: - Data Fetching
    
    func fetchBeforeCoordinateDailyList() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let list = try await beforeCodiUseCase.fetchBeforeCoordinateDailyList()
                self.beforeCoordinateDailyList = list
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // MARK: - Selection Logic
    
    func toggleSelection(id: Int) {
        if let selectedCodi = beforeCoordinateDailyList.first(where: { $0.id == id }) {
            navigateToAddCodiWithData(codi: selectedCodi)
        }
    }
    
    // MARK: - Navigation
    
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func navigateToAddCodiWithData(codi: BeforeCoordinateDailyEntity) {
        navigationRouter.navigate(
            to: .addCodi(
                coordinateId: coordinateId
            )
        )
    }
    
    func navigateToSpecificLookBook(id: Int) {
        navigationRouter.navigate(to: .specificLookbook(lookbookId: id))
    }
}
