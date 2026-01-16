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
    private let specificLookBookUseCase: SpecificLookBookUseCase

    let lookbookId: Int
    @Published var lookbookTitle: String
    
    // MARK: - Published State (Data)
    
    @Published var specificLookBookCodiList: [SpecificLookBookCodiEntity] = []
    @Published private(set) var likedCodiIds: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published State (Editing)
    
    @Published var isEditing: Bool = false
    @Published var selectedCodiIds: Set<Int> = []
    @Published var isShowingDeleteAlert: Bool = false
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        specificLookBookUseCase: SpecificLookBookUseCase,
        lookbookId: Int,
        lookbookTitle: String = ""
    ) {
        self.navigationRouter = navigationRouter
        self.specificLookBookUseCase = specificLookBookUseCase
        self.lookbookId = lookbookId
        self.lookbookTitle = lookbookTitle
    }
    
    // MARK: - Data Fetching
    // 특정 룩북의 코디 조회하기
    // MARK: - Data Fetching
    func fetchCodis() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let list = try await specificLookBookUseCase.fetchCodisForLookBook(forLookbookId: lookbookId)
                self.specificLookBookCodiList = list
                
                // 추가: 서버에서 받아온 좋아요 상태를 즉시 반영
                let initiallyLikedIds = list.filter { $0.coordinateLiked }.map { $0.id }
                self.likedCodiIds = Set(initiallyLikedIds)
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    // MARK: - Like Action
    func toggleLike(codyId: Int) {
        let isCurrentlyLiked = likedCodiIds.contains(codyId)

        if isCurrentlyLiked {
            likedCodiIds.remove(codyId)
        } else {
            likedCodiIds.insert(codyId)
        }

        Task {
            do {
                try await specificLookBookUseCase.toggleLike(
                    coordinateId: codyId,
                    isLiked: !isCurrentlyLiked
                )
            } catch {
                if isCurrentlyLiked {
                    likedCodiIds.insert(codyId)
                } else {
                    likedCodiIds.remove(codyId)
                }
                self.errorMessage = "좋아요 상태 변경에 실패했습니다."
            }
        }
    }
    
    // MARK: - Editing Actions
    
    // 토글 - 추가하기
    func toggleSelection(id: Int) {
        if selectedCodiIds.contains(id) {
            selectedCodiIds.remove(id)
        } else {
            selectedCodiIds.insert(id)
        }
    }
    
    // 토글 - 편집하기
    func toggleEditingMode() {
        isEditing.toggle()
        if !isEditing {
            selectedCodiIds = []
        }
    }
    
    // 코디 삭제 중
    func handleDeleteAction() {
        isEditing = true
    }
    
    // topBar 삭제 버튼 동작
    func handleCompleteAction() {
        guard !selectedCodiIds.isEmpty else {
            toggleEditingMode()
            return
        }
        isShowingDeleteAlert = true
    }
    
    // alert 삭제 버튼 동작
    func beginDelete() {
        isShowingDeleteAlert = false
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            self.confirmDelete()
        }
    }
    
    func confirmDelete() {
        let idsToDelete = Array(selectedCodiIds)

        isLoading = true

        Task {
            do {
                try await specificLookBookUseCase.deleteCodis(
                    ids: idsToDelete,
                    lookbookId: lookbookId
                )

                fetchCodis()
                toggleEditingMode()
            } catch {
                self.errorMessage = "코디 삭제에 실패했습니다."
            }

            isLoading = false
        }
    }
    
    // MARK: - Navigation
    
    // 코디 추가하기 후 화면 전환
    func navigateToAddCodi() {
        navigationRouter.navigate(to: .addCodi(coordinateId: lookbookId))
    }
    
    // 특정 코디 상세 뷰 전환
    func navigateToCodiDetail(codiId: Int) {
        navigationRouter.navigate(to: .codiDetail(codiId: codiId, lookbookId: lookbookId))
    }
    
    // 뒤로가기
    func handleBackTap() {
        if isEditing {
            toggleEditingMode()
        } else {
            navigationRouter.navigateBack()
        }
    }
}
