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
            .sink { [weak self] _ in
                Task {
                    await self?.loadPosts()
                }
            }
            .store(in: &cancellables)
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
            let sort = currentSort == "전체" ? nil : currentSort
            self.posts = try await useCase.fetchPosts(query: self.initialQuery, sort: sort)
        } catch {
            #if DEBUG
            print("[Search] 게시물 로딩 실패: \(error.localizedDescription)")
            #endif
        }
    }

    func loadUsers() async {
        do {
            self.allUsers = try await useCase.fetchUsers(query: self.initialQuery)
            self.users = self.allUsers
        } catch {
            #if DEBUG
            print("[Search] 유저 로딩 실패: \(error.localizedDescription)")
            #endif
        }
    }

    func executeNewSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty { return }

        RecentSearchStorage.addTerm(trimmedQuery)
        self.initialQuery = trimmedQuery
        self.currentSort = "전체"

        Task {
            await loadPosts()
            await loadUsers()
        }
    }
    
    // MARK: - Navigation

    func handleBackTap() {
        navigationRouter.navigateBack()
    }

    func navigateToUserProfile(userId: Int) {
        navigationRouter.navigate(to: .otherProfile(userId: userId))
    }

    func navigateToFeedDetail(feedId: Int) {
        navigationRouter.navigate(to: .feedDetail(feedId: feedId))
    }
}
