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
    
//    private func navigateToAddCodiWithData(codi: BeforeCoordinateDailyEntity) {
//        navigationRouter.navigateBack()
//    }
    private func navigateToAddCodiWithData(codi: BeforeCoordinateDailyEntity) {
        // 1. Combine 통로로 데이터 전송
        AddCodiViewModel.beforeCodiSelected.send(codi)
        // 2. 현재 화면 닫기 (이전 AddCodiView로 돌아감)
        navigationRouter.navigateBack()
    }
}

// MARK: - Private Helpers

private extension AddBeforeCodiViewModel {
    func handleError(_ error: Error) {
        print("DEBUG: 이전 코디 목록 로드 실패 - \(error.localizedDescription)")
        self.errorMessage = "데이터 로드에 실패했습니다. 다시 시도해주세요."
    }
}
