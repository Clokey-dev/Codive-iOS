//
//  SearchRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

final class SearchRepositoryImpl: SearchRepository {
    // MARK: - Properties
    private let datasource: SearchDataSource
    
    // MARK: - Initializer
    init(datasource: SearchDataSource) {
        self.datasource = datasource
    }
    
    // MARK: - Methods (SearchRepository Protocol Implementation)
    
    func fetchUserName() -> SearchEntity {
        return datasource.fetchUserName()
    }
    
    func fetchRecentSearchTags() -> [SearchTagEntity] {
        return datasource.fetchRecentSearchTags()
    }
    
    func fetchRecommendedNews() -> [NewsEntity] {
        return datasource.fetchRecommendedNews()
    }
    
    func fetchPosts(query: String) -> [PostEntity] {
        return datasource.fetchPosts(query: query)
    }
    
    func fetchUsers(query: String) -> [SimpleUser] {
        return datasource.fetchUsers(query: query)
    }
}
