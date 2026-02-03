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
    private let listUseCase: LookBookMainUseCase
    
    // MARK: - Published State (Data)
    
    @Published var lookBookList: [LookBookEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published State (Editing)
    
    @Published var isEditing: Bool = false
    @Published var selectedLookBookId: Int64?
    
    // MARK: - Published State (Dialog / Alert)
    
    @Published var isShowingDeleteAlert: Bool = false
    @Published var isShowingAddDialog: Bool = false
    @Published var isShowingCancelConfirmAlert: Bool = false
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        listUseCase: LookBookMainUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.listUseCase = listUseCase
    }
    
    // MARK: - 룩북 전체 조회
    func fetchLookBooks() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await listUseCase.fetchLookBookList(lastLookBookId: nil, size: 10, direction: .DESC)
                self.lookBookList = result.content
                
                if result.content.isEmpty {
                    self.isShowingAddDialog = true
                }
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // MARK: - 룩북 삭제 토글
    func toggleDeleteMode() {
        isEditing.toggle()
        if !isEditing {
            selectedLookBookId = nil
        }
    }
    
    // MARK: - 삭제할 룩북 선택
    func toggleSelection(id: Int64) {
        if selectedLookBookId == id {
            selectedLookBookId = nil
        } else {
            selectedLookBookId = id
        }
    }
    
    // MARK: - 룩북 삭제 동작
    func handleDeleteAction() {
        toggleDeleteMode()
    }
    
    // MARK: - alert 삭제 동작
    func handleCompleteAction() {
        guard selectedLookBookId != nil else {
            toggleDeleteMode()
            return
        }
        isShowingDeleteAlert = true
    }
    
    // MARK: - alert 삭제 동작 후 복귀
    func beginDelete() {
        isShowingDeleteAlert = false
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            self.confirmDelete()
        }
    }
    
    // MARK: - 룩북 삭제 확정
    func confirmDelete() {
        guard let idToDelete = selectedLookBookId else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await listUseCase.deleteLookBook(lookBookId: idToDelete)
                
                let updatedResult = try await listUseCase.fetchLookBookList(
                    lastLookBookId: nil,
                    size: 10,
                    direction: .DESC
                )
                self.lookBookList = updatedResult.content
                
                self.handleDeleteAction()
            } catch {
                self.errorMessage = "룩북 삭제에 실패했습니다."
            }
            isLoading = false
        }
    }
    
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
        
        isLoading = true
        errorMessage = nil
        
        let request = CreateLookBookAPIRequestDTO(name: trimmedTitle)
        
        Task {
            do {
                _ = try await listUseCase.createLookBook(request: request)
                
                let updatedResult = try await listUseCase.fetchLookBookList(
                    lastLookBookId: nil,
                    size: 10,
                    direction: .DESC
                )
                self.lookBookList = updatedResult.content
                self.isShowingAddDialog = false
            } catch {
                self.errorMessage = "룩북 생성에 실패했습니다."
            }
            isLoading = false
        }
    }
    
    // MARK: - Navigation
    
    func handleBackTap() {
        if isEditing {
            handleDeleteAction()
        } else {
            navigationRouter.navigateBack()
        }
    }
    
    func navigateToSpecificLookBook(id: Int64) {
        guard let lookBook = lookBookList.first(where: { $0.lookBookId == id }) else {
            return
        }
        
        navigationRouter.navigate(
            to: .specificLookbook(
                lookbookId: lookBook.lookBookId,
                name: lookBook.lookbookName
            )
        )
    }
}
