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
    
    @Published var recentSearchTags: [SearchTagEntity] = []
    @Published var recommendedNews: [NewsEntity] = []
    @Published var showingDeleteAlert: Bool = false
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: SearchUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        
        loadData()
    }
    
    func loadData() {
        self.recentSearchTags = useCase.fetchRecentSearchTags()
        self.recommendedNews = useCase.fetchRecommendedNews()
    }
    
    func executeSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            print("검색어를 입력해 주세요.")
            return
        }
        // query를 전달하도록 수정
        navigationRouter.navigate(to: .searchResult(query: trimmedQuery))
        print("검색 실행: \(trimmedQuery). SearchResultView로 이동 필요.")
    }
    
    func deleteTag(tag: SearchTagEntity) {
        if let index = recentSearchTags.firstIndex(where: { $0.id == tag.id }) {
            recentSearchTags.remove(at: index)
            print("태그 삭제 완료: \(tag.text)")
        }
    }
    
    func handleDeleteAll() {
        self.showingDeleteAlert = true
    }
    
    func executeDeleteAll() {
        print("최근 검색어 전체 삭제 실행 완료")
        self.recentSearchTags = []
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}

// MARK: - Preview Support
extension SearchViewModel {
    static var preview: SearchViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = SearchDataSource()
        let mockRepository = SearchRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = SearchUseCase(repository: mockRepository)
        
        return SearchViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase
        )
    }
}
