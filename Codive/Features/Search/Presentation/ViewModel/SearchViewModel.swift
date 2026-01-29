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
        // 1. 로컬 데이터 (동기)
        let user = useCase.fetchUserName()
        self.username = user.username
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
                print("❌ 추천 검색 로딩 실패:", error)
                self.recommendedNews = []
            }
        }
    }
    
    func executeSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            print("검색어를 입력해 주세요.")
            return
        }

        navigationRouter.navigate(to: .searchResult(query: trimmedQuery))
        print("검색 실행: \(trimmedQuery). SearchResultView로 이동 필요.")
    }
    
    func deleteTag(tag: SearchTagEntity) {
        if let index = recentSearchTags.firstIndex(where: { $0.id == tag.id }) {
            recentSearchTags.remove(at: index)
            print("태그 삭제 완료: \(tag.text)")
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
