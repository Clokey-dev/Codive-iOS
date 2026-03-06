//
//  SearchViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: SearchUseCase

    @Published var username: String = ""
    @Published var recentSearchItems: [RecentSearchItem] = []
    @Published var recommendedNews: [SearchRecommendationEntity] = []

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: SearchUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }

    // MARK: - Methods

    func loadData() {
        if let profile = UserProfileStorage.load() {
            self.username = profile.nickname
        }
    }

    func loadRecentSearchItems() {
        self.recentSearchItems = RecentSearchStorage.load()
    }

    func loadSearchRecommendation() {
        Task {
            do {
                let recommendations = try await useCase.fetchSearchRecommendation()

                self.recommendedNews = recommendations.map {
                    SearchRecommendationEntity(
                        historyId: $0.historyId,
                        memberId: $0.memberId,
                        recommendType: $0.recommendType,
                        title: $0.title,
                        subTitle: $0.subTitle,
                        imageUrl: $0.imageUrl
                    )
                }
            } catch {
                #if DEBUG
                print("[Search] 추천 검색 로딩 실패:", error)
                #endif
                self.recommendedNews = []
            }
        }
    }

    func executeSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty { return }

        RecentSearchStorage.addTerm(trimmedQuery)
        loadRecentSearchItems()
        navigationRouter.navigate(to: .searchResult(query: trimmedQuery))
    }

    /// 추천 소식 키워드로 검색 실행
    func searchWithKeyword(_ keyword: String) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKeyword.isEmpty else { return }

        RecentSearchStorage.addTerm(trimmedKeyword)
        loadRecentSearchItems()
        navigationRouter.navigate(to: .searchResult(query: trimmedKeyword))
    }

    func deleteItem(_ item: RecentSearchItem) {
        RecentSearchStorage.removeItem(item)
        loadRecentSearchItems()
    }

    func handleShowAll() {
        navigationRouter.navigate(to: .recentlySearchResult)
    }

    func handleItemTap(_ item: RecentSearchItem) {
        switch item {
        case .keyword(let text):
            executeSearch(query: text)
        case .member(let userId, _, _):
            if let id = Int(userId) {
                RecentSearchStorage.addItem(item)
                loadRecentSearchItems()
                navigationRouter.navigate(to: .otherProfile(userId: id))
            }
        }
    }

    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
