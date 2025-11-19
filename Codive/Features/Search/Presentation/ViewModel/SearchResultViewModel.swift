//
//  SearchResultViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/19/25.
//

import SwiftUI
import Combine

struct ViewModelSortOption: Identifiable, Hashable {
    let id: String
    let displayName: String
}

@MainActor
final class SearchResultViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: SearchUseCase
    private var allPosts: [PostEntity] = []
    
    @Published var posts: [PostEntity] = []
    @Published var currentSort: String = "전체"
    
    let sortOptions: [ViewModelSortOption] = [
        ViewModelSortOption(id: "전체", displayName: "전체"),
        ViewModelSortOption(id: "인기순", displayName: "인기순"),
        ViewModelSortOption(id: "최신순", displayName: "최신순")
    ]
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: SearchUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        loadPosts()
        
        $currentSort
            .removeDuplicates()
            .sink { [weak self] newSort in
                self?.applySorting(newSort: newSort)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()

    func loadPosts() {
        self.allPosts = useCase.fetchPosts()
        self.posts = self.allPosts
    }
    
    private func applySorting(newSort: String) {
        switch newSort {
        case "인기순":
            self.posts = self.allPosts.sorted { $0.likes > $1.likes }
        case "최신순":
            self.posts = self.allPosts.sorted { $0.date > $1.date }
        case "전체":
            self.posts = self.allPosts
        default:
            break
        }
        print("정렬 적용 완료: \(newSort), 결과 \(self.posts.count)개")
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}

// MARK: - Preview Support
extension SearchResultViewModel {
    static var preview: SearchResultViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = SearchDataSource()
        let mockRepository = SearchRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = SearchUseCase(repository: mockRepository)
        
        return SearchResultViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase
        )
    }
}
