//
//  SpecificLookBookViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/27/25.
//

import SwiftUI

@MainActor
final class SpecificLookBookViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    
    @Published var lookBookList: [LookBookEntity] = [] 
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    let lookbookId: Int
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase, lookbookId: Int) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.lookbookId = lookbookId
        print("SpecificLookBookViewModel initialized for LookBook ID: \(lookbookId)")
    }
    
    func fetchCodis() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let list = try await useCase.fetchCodis(forLookbookId: lookbookId)
                self.lookBookList = list
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func toggleLike(codyId: Int, isLiked: Bool) {
        Task {
            do {
                try await useCase.toggleLike(codyId: codyId, isLiked: isLiked)
            } catch {
                self.errorMessage = "좋아요 상태 변경에 실패했습니다: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}

extension SpecificLookBookViewModel {
    static var preview: SpecificLookBookViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = LookBookDataSource()
        let mockRepository = LookBookRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = LookBookUseCase(repository: mockRepository)
        return SpecificLookBookViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase,
            lookbookId: 1
        )
    }
}
