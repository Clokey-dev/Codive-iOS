//
//  LookBookViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import SwiftUI

@MainActor
final class LookBookViewModel: ObservableObject {
    
    // MARK: - Dependencies
    
    let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    
    // MARK: - Published State (Data)
    
    @Published var lookBookList: [LookBookEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published State (Editing)
    
    @Published var isEditing: Bool = false
    @Published var selectedLookBookIds: Set<Int> = []
    
    // MARK: - Published State (Dialog / Alert)
    
    @Published var isShowingDeleteAlert: Bool = false
    @Published var isShowingAddDialog: Bool = false
    @Published var isShowingCancelConfirmAlert: Bool = false
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        useCase: LookBookUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }
    
    // MARK: - Data Fetching
    
    func fetchLookBooks() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let list = try await useCase.fetchLookBookList()
                self.lookBookList = list
                
                if list.isEmpty {
                    self.isShowingAddDialog = true
                }
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
    
    func beginDelete() {
        isShowingDeleteAlert = false
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            self.confirmDelete()
        }
    }
    
    func confirmDelete() {
        let idsToDelete = Array(selectedLookBookIds)
        
        Task {
            do {
                try await useCase.deleteLookBooks(ids: idsToDelete)
                self.isLoading = false
                self.fetchLookBooks()
                self.toggleEditingMode()
            } catch {
                self.errorMessage = "룩북 삭제에 실패했습니다: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Dialog Actions
    
    func toggleAddDialog() {
        isShowingAddDialog.toggle()
    }
    
    func handleDialogCancelTap() {
        isShowingCancelConfirmAlert = true
    }
    
    func confirmCancelDialog() {
        isShowingCancelConfirmAlert = false
        isShowingAddDialog = false
    }
    
    func handleAddLookBook(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newLookBook = LookBookEntity(
            id: Int.random(in: 1000...9999),
            imageURL: "https://via.placeholder.com/160",
            cardTitle: trimmedTitle
        )
        withAnimation {
            self.lookBookList.append(newLookBook)
        }
        
        isShowingAddDialog = false
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
