//
//  AddBeforeCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

@MainActor
final class AddBeforeCodiViewModel: ObservableObject {
    
    // MARK: - Properties (State)
    
    @Published var beforeCoordinateDailyList: [BeforeCoordinateDailyEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedLookBookIds: Set<Int> = []
    
    // MARK: - Properties (Dependencies)
    
    private let navigationRouter: NavigationRouter
    private let beforeCodiUseCase: BeforeCodiUseCase
    private let coordinateId: Int64
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        beforeCodiUseCase: BeforeCodiUseCase,
        coordinateId: Int64
    ) {
        self.navigationRouter = navigationRouter
        self.beforeCodiUseCase = beforeCodiUseCase
        self.coordinateId = coordinateId
    }
    
    func fetchBeforeCoordinateDailyList() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await beforeCodiUseCase.fetchPastCoordinates(
                    lastCoordinateId: nil,
                    size: 20,
                    direction: .DESC
                )
                
                self.beforeCoordinateDailyList = result.content
            } catch {
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    func toggleSelection(id: Int64) {
        guard let selectedCodi = beforeCoordinateDailyList.first(where: { $0.id == id }) else { return }
        navigateToAddCodiWithData(codi: selectedCodi)
    }
    
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    private func navigateToAddCodiWithData(codi: BeforeCoordinateDailyEntity) {
        AddCodiViewModel.beforeCodiSelected.send(codi)
        navigationRouter.navigateBack()
    }
}

// MARK: - Private Helpers

private extension AddBeforeCodiViewModel {
    func handleError(_ error: Error) {
        #if DEBUG
        print("[Codi] 이전 코디 목록 로드 실패: \(error.localizedDescription)")
        #endif
        self.errorMessage = "데이터 로드에 실패했습니다. 다시 시도해주세요."
    }
}
