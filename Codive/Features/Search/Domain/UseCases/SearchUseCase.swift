//
//  SearchUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

final class SearchUseCase {
    // MARK: - Properties
    private let repository: SearchRepository
    
    // MARK: - Initializer
    init(repository: SearchRepository) {
        self.repository = repository
    }
    
    // MARK: - Fetch Methods
    
    func fetchUserName() -> SearchEntity {
        return repository.fetchUserName()
    }
    
    func fetchRecentSearchTags() -> [SearchTagEntity] {
        return repository.fetchRecentSearchTags()
    }
    
    func fetchRecommendedNews() -> [NewsEntity] {
        return repository.fetchRecommendedNews()
    }
    
    func fetchPosts(query: String, sort: String?) async throws -> [PostEntity] {
        return try await repository.fetchPosts(query: query, sort: sort)
    }

    func fetchUsers(query: String) async throws -> [SimpleUser] {
        return try await repository.fetchUsers(query: query)
    }
}
