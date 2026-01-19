//
//  SpecificLookBookViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/27/25.
//

import SwiftUI

@MainActor
final class SpecificLookBookViewModel: ObservableObject {
    
    // MARK: - Dependencies
    
    private let navigationRouter: NavigationRouter
    private let detailUseCase: LookBookDetailUseCase
    private let codiUseCase: CodiUseCase

    let lookbookId: Int
    let lookbookTitle: String
    
    // MARK: - Published State (Data)
    
    @Published var lookBookList: [LookBookEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published State (Editing)
    
    @Published var isEditing: Bool = false
    @Published var selectedCodiIds: Set<Int> = []
    @Published var isShowingDeleteAlert: Bool = false
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        detailUseCase: LookBookDetailUseCase,
        codiUseCase: CodiUseCase,
        lookbookId: Int,
        lookbookTitle: String = ""
    ) {
        self.navigationRouter = navigationRouter
        self.detailUseCase = detailUseCase
        self.codiUseCase = codiUseCase
        self.lookbookId = lookbookId
        self.lookbookTitle = lookbookTitle
    }
    
    // MARK: - Data Fetching
    
    func fetchCodis() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let list = try await detailUseCase.fetchCodis(forLookbookId: lookbookId)
                self.lookBookList = list
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // MARK: - Editing Actions
    
    func toggleEditingMode() {
        isEditing.toggle()
        if !isEditing {
            selectedCodiIds = []
        }
    }
    
    func toggleSelection(id: Int) {
        if selectedCodiIds.contains(id) {
            selectedCodiIds.remove(id)
        } else {
            selectedCodiIds.insert(id)
        }
    }
    
    func handleDeleteAction() {
        isEditing = true
    }
    
    func handleCompleteAction() {
        guard !selectedCodiIds.isEmpty else {
            toggleEditingMode()
            return
        }
        isShowingDeleteAlert = true
    }
    
    func beginDelete() {
        isShowingDeleteAlert = false
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            self.confirmDelete()
        }
    }
    
    func confirmDelete() {
        Task {
            fetchCodis()
            toggleEditingMode()
        }
    }
    
    // MARK: - Like Action
    
    func toggleLike(codyId: Int, isLiked: Bool) {
        Task {
            do {
                try await codiUseCase.toggleLike(codyId: codyId, isLiked: isLiked)
            } catch {
                self.errorMessage = "좋아요 상태 변경에 실패했습니다: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Navigation
    
    func navigateToAddCodi() {
        navigationRouter.navigate(to: .addCodi(lookbookId: lookbookId))
    }
    
    func navigateToCodiDetail(codiId: Int) {
        navigationRouter.navigate(to: .codiDetail(codiId: codiId, lookbookId: lookbookId))
    }
    
    func handleBackTap() {
        if isEditing {
            toggleEditingMode()
        } else {
            navigationRouter.navigateBack()
        }
    }
}
