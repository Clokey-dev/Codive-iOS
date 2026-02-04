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
                
                if result.content.isEmpty {
//                    self.isShowingAddDialog = true
                }
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
        // 1. 먼저 화면 이동을 지시합니다.
        navigationRouter.navigate(to: .lookbook)
        
        // 2. 화면이 생성될 시간을 아주 잠깐(0.1초) 벌어준 뒤 신호를 보냅니다.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            LookBookEventManager.shared.shouldShowAddDialog.send(true)
        }
    }
}
