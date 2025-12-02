//
//  LookBookViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import SwiftUI

@MainActor
final class LookBookViewModel: ObservableObject {
    // MARK: - Properties
    let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    
    @Published var lookBookList: [LookBookEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var isEditing: Bool = false
    @Published var selectedLookBookIds: Set<Int> = []
    
    @Published var isShowingDeleteAlert: Bool = false
    
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
                let list = try await useCase.fetchLookBookList()
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
            selectedLookBookIds = []
        }
    }
    
    func toggleSelection(id: Int) {
        if selectedLookBookIds.contains(id) {
            selectedLookBookIds.remove(id)
        } else {
            selectedLookBookIds.insert(id)
        }
    }

    func handleDeleteAction() {
        toggleEditingMode()
    }
    
    func handleCompleteAction() {
        guard !selectedLookBookIds.isEmpty else {
            toggleEditingMode()
            return
        }

        isShowingDeleteAlert = true
    }

    func confirmDelete() {
        isShowingDeleteAlert = false
        
        isLoading = true
        errorMessage = nil
        
        let idsToDelete = Array(selectedLookBookIds)
        
        Task {
            do {
                try await useCase.deleteLookBooks(ids: idsToDelete)
                self.fetchLookBooks()
                self.toggleEditingMode()
            } catch {
                self.errorMessage = "룩북 삭제에 실패했습니다: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    // MARK: - Navigation
    func handleBackTap() {
        if isEditing {
            toggleEditingMode()
        } else {
            navigationRouter.navigateBack()
        }
    }
    
    func navigateToSpecificLookBook(id: Int) {
        navigationRouter.navigate(to: .specificLookbook(lookbookId: id))
    }
}

extension LookBookViewModel {
    static var preview: LookBookViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = LookBookDataSource()
        let mockRepository = LookBookRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = LookBookUseCase(repository: mockRepository)
        return LookBookViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase
        )
    }
}
