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
    private var allUsers: [SimpleUser] = []
    private var initialQuery: String
    
    @Published var posts: [PostEntity] = []
    @Published var users: [SimpleUser] = []         
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
        self.initialQuery = initialQuery
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

    func loadInitialData() {
        Task {
            await loadPosts()
            await loadUsers()
        }
    }

    func loadPosts() async {
        do {
            self.allPosts = try await useCase.fetchPosts(query: self.initialQuery)
            self.posts = self.allPosts
            self.applySorting(newSort: self.currentSort)
        } catch {
            print("게시물 로딩 실패: \(error.localizedDescription)")
        }
    }

    func loadUsers() async {
        do {
            self.allUsers = try await useCase.fetchUsers(query: self.initialQuery)
            self.users = self.allUsers
            print("유저 로딩 완료: \(self.users.count)명")
        } catch {
            print("유저 로딩 실패: \(error.localizedDescription)")
        }
    }

    func executeNewSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            print("검색어를 입력해 주세요.")
            return
        }

        self.initialQuery = trimmedQuery
        self.currentSort = "전체"

        Task {
            await loadPosts()
            await loadUsers()
            print("현재 페이지에서 검색 결과 갱신: \(trimmedQuery)")
        }
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
