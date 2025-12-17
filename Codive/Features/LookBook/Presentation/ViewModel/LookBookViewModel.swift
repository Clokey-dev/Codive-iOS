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
    @Published var isShowingAddDialog: Bool = false
    @Published var isShowingCancelConfirmAlert: Bool = false
    
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

    func confirmDelete() {
        isShowingDeleteAlert = false
        isLoading = true
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
    
    // 수정됨: 텍스트를 입력받아 리스트에 카드를 추가함
    func handleAddLookBook(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        // 새로운 임시 엔티티 생성
        let newLookBook = LookBookEntity(
            id: Int.random(in: 1000...9999), // 실제 서버 연동 시 서버에서 생성된 ID 사용
            imageURL: "https://via.placeholder.com/160",
            cardTitle: trimmedTitle
        )
        
        // 리스트에 추가
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
