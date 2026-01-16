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
    private let coordinateId: Int
    
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
    
    // MARK: - API / Data Fetching
    
    /// 서버로부터 이전 코디 기록 목록을 가져옵니다.
    func fetchBeforeCoordinateDailyList() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let list = try await beforeCodiUseCase.fetchBeforeCoordinateDailyList()
                self.beforeCoordinateDailyList = list
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    // MARK: - Selection Logic
    
    /// 리스트에서 특정 코디를 선택했을 때의 처리를 담당합니다.
    func toggleSelection(id: Int) {
        guard let selectedCodi = beforeCoordinateDailyList.first(where: { $0.id == id }) else { return }
        
        // 선택된 코디 정보를 가지고 추가 화면으로 이동
        navigateToAddCodiWithData(codi: selectedCodi)
    }
    
    // MARK: - Navigation
    
    /// 이전 화면으로 돌아갑니다.
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    /// 선택된 데이터를 기반으로 코디 추가 화면으로 이동합니다.
    private func navigateToAddCodiWithData(codi: BeforeCoordinateDailyEntity) {
        navigationRouter.navigate(
            to: .addCodi(coordinateId: coordinateId)
        )
    }
    
    /// 특정 룩북 상세 화면으로 이동합니다.
    func navigateToSpecificLookBook(id: Int) {
        navigationRouter.navigate(to: .specificLookbook(lookbookId: id))
    }
}

// MARK: - Private Helpers

private extension AddBeforeCodiViewModel {
    
    /// 에러 발생 시 처리 로직
    func handleError(_ error: Error) {
        print("DEBUG: 이전 코디 목록 로드 실패 - \(error.localizedDescription)")
        self.errorMessage = "데이터 로드에 실패했습니다. 다시 시도해주세요."
    }
}
