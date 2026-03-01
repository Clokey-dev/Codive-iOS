//
//  SpecificLookBookViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/27/25.
//

import SwiftUI

@MainActor
final class SpecificLookBookViewModel: ObservableObject {
    private let navigationRouter: NavigationRouter
    private let specificLookBookUseCase: SpecificLookBookUseCase
    
    @Published var isOverflowMenuExpanded: Bool = false
    
    private let lookbookId: Int64
    @Published var name: String
    @Published var isEditingTitle = false
    private var previousTitle: String = ""
    
    @Published var specificLookBookCodiList: [SpecificLookBookCodiEntity] = []
    @Published var likedCodiId: Int64?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isEditing: Bool = false
    @Published var selectedCodiId: Int64?
    @Published var isShowingDeleteAlert: Bool = false
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        specificLookBookUseCase: SpecificLookBookUseCase,
        lookbookId: Int64,
        name: String
    ) {
        self.navigationRouter = navigationRouter
        self.specificLookBookUseCase = specificLookBookUseCase
        self.lookbookId = lookbookId
        self.name = name
    }
    
    // MARK: - 특정 룩북의 코디 조회하기
    func fetchCodis() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await specificLookBookUseCase.fetchLookBookCoordinateList(
                    lookBookId: lookbookId,
                    lastCoordinateId: nil,
                    size: 20,
                    direction: .DESC
                )
                
                self.specificLookBookCodiList = result.content
                
                self.likedCodiId = result.content.first { $0.coordinateLiked }?.coordinateId
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다."
            }
            
            isLoading = false
        }
    }
    
    // MARK: - 코디 좋아요 토글
    func toggleLike(coordinateId: Int64) {
        Task {
            do {
                try await specificLookBookUseCase.toggleCoordinateLike(
                    coordinateId: coordinateId
                )
                
                if let currentLikedId = likedCodiId,
                   let currentIndex = specificLookBookCodiList.firstIndex(where: { $0.id == currentLikedId }) {
                    specificLookBookCodiList[currentIndex].coordinateLiked = false
                }
                
                if likedCodiId == coordinateId {
                    likedCodiId = nil
                } else {
                    likedCodiId = coordinateId
                    if let newIndex = specificLookBookCodiList.firstIndex(where: { $0.id == coordinateId }) {
                        specificLookBookCodiList[newIndex].coordinateLiked = true
                    }
                }
            } catch {
                errorMessage = "좋아요 처리에 실패했습니다."
            }
        }
    }
    
    func toggleSelection(id: Int64) {
        if selectedCodiId == id {
            selectedCodiId = nil
        } else {
            selectedCodiId = id
        }
    }
    
    // MARK: - 토글(편집하기)
    func toggleEditingMode() {
        isEditing.toggle()
        if !isEditing {
            selectedCodiId = nil
        }
    }
    
    // MARK: - 코디 편집 모드 전환
    func handleEditAction() {
        isOverflowMenuExpanded = false
        isEditing = true
    }
    
    // MARK: - topBar 삭제 버튼 동작
    func handleCompleteAction() {
        guard selectedCodiId != nil else {
            toggleEditingMode()
            return
        }
        isShowingDeleteAlert = true
    }
    
    // MARK: - alert 삭제 버튼
    func beginDelete() {
        isShowingDeleteAlert = false
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            self.confirmDelete()
        }
    }
    
    // MARK: - 코디 삭제 확정
    func confirmDelete() {
        guard let idToDelete = selectedCodiId else {
            isLoading = false
            isEditing = false
            return
        }
        
        Task {
            do {
                try await specificLookBookUseCase.deleteCoordinate(coordinateId: idToDelete)
                
                specificLookBookCodiList.removeAll { codi in
                    codi.id == idToDelete
                }
                
                selectedCodiId = nil
                isEditing = false
            } catch {
                errorMessage = "코디 삭제에 실패했습니다."
            }
            
            isLoading = false
        }
    }
    
    // MARK: - 룩북 이름 수정 시작
    func beginEditTitle() {
        previousTitle = name
        isEditingTitle = true
    }
    
    // MARK: - 룩북 이름 수정 확정
    func confirmEditTitle() {
        let newTitle = name.trimmingCharacters(in: .whitespaces)
        
        guard !newTitle.isEmpty, newTitle != previousTitle else {
            cancelEditTitle()
            return
        }
        
        isEditingTitle = false
        isLoading = true
        
        let request = UpdateLookBookAPIRequestDTO(
            name: newTitle
        )
        
        Task {
            do {
                try await specificLookBookUseCase.updateLookBook(
                    lookBookId: lookbookId,
                    request: request
                )
            } catch {
                name = previousTitle
                errorMessage = "룩북 이름 수정에 실패했습니다."
            }
            
            isLoading = false
        }
    }
    
    // MARK: - 룩북 이름 수정 취소
    func cancelEditTitle() {
        name = previousTitle
        isEditingTitle = false
    }
    
    func toggleOverflowMenu() {
        isOverflowMenuExpanded.toggle()
    }
    
    func closeOverflowMenu() {
        isOverflowMenuExpanded = false
    }
    
    func navigateToAddCodi() {
        isOverflowMenuExpanded = false
        navigationRouter.navigate(to: .addCodi(lookBookId: lookbookId))
    }
    
    func navigateToCodiDetail(codiId: Int) {
        navigationRouter.navigate(to: .codiDetail(codiId: codiId))
    }
    
    func handleBackTap() {
        if isEditing {
            toggleEditingMode()
            confirmEditTitle()
        } else {
            navigationRouter.navigateBack()
//            confirmEditTitle()
        }
    }
}
