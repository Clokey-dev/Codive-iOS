//
//  LookBookViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import SwiftUI
import Combine

@MainActor
final class LookBookViewModel: ObservableObject {
    
    // MARK: - Dependencies
    
    let navigationRouter: NavigationRouter
    private let listUseCase: LookBookMainUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published State (Data)
    
    @Published var lookBookList: [LookBookEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published State (Editing)
    
    @Published var isEditing: Bool = false
    @Published var isOverflowMenuExpanded: Bool = false
    @Published var selectedLookBookIds: Set<Int64> = []
    
    // MARK: - Published State (Dialog / Alert)
    
    @Published var isShowingDeleteAlert: Bool = false
    @Published var isShowingAddDialog: Bool = false
    @Published var isShowingCancelConfirmAlert: Bool = false
    @Published var isShowingErrorAlert: Bool = false
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        listUseCase: LookBookMainUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.listUseCase = listUseCase
        
        setupBindings()
    }
    
    private func setupBindings() {
        LookBookEventManager.shared.shouldShowAddDialog
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldShow in
                if shouldShow {
                    self?.isShowingAddDialog = true
                    // ⚠️ 한 번 띄웠으면 다시 초기화해주어야 다음 진입 시 중복으로 뜨지 않습니다.
                    LookBookEventManager.shared.shouldShowAddDialog.send(false)
                }
            }
            .store(in: &cancellables)
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
            selectedLookBookIds.removeAll()
        }
    }

    // MARK: - 삭제할 룩북 선택
    func toggleSelection(id: Int64) {
        if selectedLookBookIds.contains(id) {
            selectedLookBookIds.remove(id)
        } else {
            selectedLookBookIds.insert(id)
        }
    }
    
    // MARK: - 룩북 삭제 동작
    func handleDeleteAction() {
        isOverflowMenuExpanded = false
        toggleDeleteMode()
    }
    
    // MARK: - alert 삭제 동작
    func handleCompleteAction() {
        guard !selectedLookBookIds.isEmpty else {
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
        guard !selectedLookBookIds.isEmpty else {
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                for id in selectedLookBookIds {
                    try await listUseCase.deleteLookBook(lookBookId: id)
                }

                let updatedResult = try await listUseCase.fetchLookBookList(
                    lastLookBookId: nil,
                    size: 10,
                    direction: .DESC
                )
                self.lookBookList = updatedResult.content

                self.handleDeleteAction()
            } catch {
                self.errorMessage = "룩북 삭제에 실패했습니다: \(error.localizedDescription)"
                self.isShowingErrorAlert = true
            }
            isLoading = false
        }
    }
    
    func toggleAddDialog() {
        isOverflowMenuExpanded = false
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
    
    func toggleOverflowMenu() {
        isOverflowMenuExpanded.toggle()
    }
    
    func closeOverflowMenu() {
        isOverflowMenuExpanded = false
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

extension UIImage {
    func toBase64String() -> String? {
        guard let data = self.jpegData(compressionQuality: 0.9) else {
            return nil
        }
        return data.base64EncodedString()
    }
}
