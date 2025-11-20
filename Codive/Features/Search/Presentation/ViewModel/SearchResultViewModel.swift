//
//  SearchResultViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/19/25.
//

import SwiftUI
import Combine

@MainActor
final class SearchResultViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: SearchUseCase
    private var allPosts: [PostEntity] = []
    private var initialQuery: String
    
    @Published var posts: [PostEntity] = []
    @Published var currentSort: String = "전체"
    @Published var searchBarText: String
    
    let sortOptions: [SortOptionEntity] = [
        SortOptionEntity(id: "전체", displayName: "전체"),
        SortOptionEntity(id: "인기순", displayName: "인기순"),
        SortOptionEntity(id: "최신순", displayName: "최신순")
    ]
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: SearchUseCase, initialQuery: String) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.initialQuery = initialQuery
        self.searchBarText = initialQuery
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
        self.allPosts = useCase.fetchPosts(query: self.initialQuery)
        self.posts = self.allPosts
        self.applySorting(newSort: self.currentSort)
    }
    
    func executeNewSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            print("검색어를 입력해 주세요.")
            return
        }
        
        self.initialQuery = trimmedQuery
        self.currentSort = "전체"
        loadPosts()
        
        // 새로운 검색 결과 화면으로 이동
        navigationRouter.navigate(to: .searchResult(query: trimmedQuery))
        print("새로운 검색 실행: \(trimmedQuery)")
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
            useCase: mockUseCase,
            initialQuery: "드뮤어룩"
        )
    }
}
