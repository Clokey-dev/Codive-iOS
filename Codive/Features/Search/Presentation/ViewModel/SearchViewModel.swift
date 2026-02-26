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
    @Published var recentSearchTags: [SearchTagEntity] = []
    @Published var recommendedNews: [SearchRecommendationEntity] = []
    @Published var showingDeleteAlert: Bool = false
    
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
    
    func recentlySearchResultList() {
        self.recentSearchTags = recentSearchTags
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

        navigationRouter.navigate(to: .searchResult(query: trimmedQuery))
    }

    /// 추천 소식 키워드로 검색 실행
    func searchWithKeyword(_ keyword: String) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKeyword.isEmpty else { return }

        navigationRouter.navigate(to: .searchResult(query: trimmedKeyword))
    }

    func deleteTag(tag: SearchTagEntity) {
        if let index = recentSearchTags.firstIndex(where: { $0.id == tag.id }) {
            recentSearchTags.remove(at: index)
        }
    }
    
    func handleShowAll() {
        navigationRouter.navigate(to: .recentlySearchResult)
    }
    
    func handleTagTap(tag: SearchTagEntity) {
        executeSearch(query: tag.text)
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
