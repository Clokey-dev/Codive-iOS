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
    private var currentQuery: String
    
    @Published var posts: [PostEntity] = []
    @Published var currentSort: String = "전체"
    @Published var searchBarText: String
    
    let sortOptions: [SortOptionEntity] = [
        SortOptionEntity(id: "전체", displayName: "전체"),
        SortOptionEntity(id: "인기순", displayName: "인기순"),
        SortOptionEntity(id: "최신순", displayName: "최신순")
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: SearchUseCase, initialQuery: String) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.currentQuery = initialQuery
        self.searchBarText = initialQuery
        
        setupBindings()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        $currentSort
            .removeDuplicates()
            .sink { [weak self] newSort in
                self?.applySorting(newSort: newSort)
            }
            .store(in: &cancellables)
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
    
    // MARK: - Public Methods
    
    func loadPosts() {
        self.allPosts = useCase.fetchPosts(query: self.currentQuery)
        self.posts = self.allPosts
        self.applySorting(newSort: self.currentSort)
    }
    
    func executeNewSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            print("검색어를 입력해 주세요.")
            return
        }
        
        // 같은 검색어면 다시 검색하지 않음
        if trimmedQuery == currentQuery {
            print("동일한 검색어입니다.")
            return
        }
        
        // 검색어 업데이트 및 데이터 새로 로드
        self.currentQuery = trimmedQuery
        self.searchBarText = trimmedQuery
        self.currentSort = "전체"
        loadPosts()
        
        print("새로운 검색 실행: \(trimmedQuery)")
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
