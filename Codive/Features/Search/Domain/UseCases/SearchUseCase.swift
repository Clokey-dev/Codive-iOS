//
//  SearchUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

final class SearchUseCase {
    private let repository: SearchRepository
    
    init(repository: SearchRepository) {
        self.repository = repository
    }
    
    func fetchUserName() -> SearchEntity {
        return repository.fetchUserName()
    }
    
    func fetchRecentSearchTags() -> [SearchTagEntity] {
        return repository.fetchRecentSearchTags()
    }
    
    func fetchRecommendedNews() -> [NewsEntity] {
        return repository.fetchRecommendedNews()
    }
    
    func fetchPosts(query: String) -> [PostEntity] { 
        return repository.fetchPosts(query: query)
    }
}
