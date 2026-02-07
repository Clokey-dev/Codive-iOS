//
//  MyLookbookSectionViewModel.swift
//  Codive
//
//  Created by 한금준 on 2/4/26.
//

import Foundation

@MainActor
final class MyLookbookSectionViewModel: ObservableObject {
    // MARK: - Private Properties
    private let navigationRouter: NavigationRouter
    private let fetchMyLookBookListUseCase: FetchMyLookBookListUseCase
    
    @Published var lookBookList: [LookBookEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(
        navigationRouter: NavigationRouter,
        fetchMyLookBookListUseCase: FetchMyLookBookListUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.fetchMyLookBookListUseCase = fetchMyLookBookListUseCase
    }
    
    func fetchMyLookBooks() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await fetchMyLookBookListUseCase.fetchLookBookList(lastLookBookId: nil, size: 10, direction: .DESC)
                self.lookBookList = result.content
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    /// 룩북으로 이동
    func navigateToLookBook() {
        navigationRouter.navigate(to: .lookbook)
    }
    
    func navigateToAddLookbook() {
        LookBookEventManager.shared.shouldShowAddDialog.send(true)
        navigationRouter.navigate(to: .lookbook)
    }
    
    func navigateToSpecificLookbook(lookBook: LookBookEntity) {
        navigationRouter.navigate(
            to: .specificLookbook(
                lookbookId: lookBook.lookBookId,
                name: lookBook.lookbookName
            )
        )
    }
}
