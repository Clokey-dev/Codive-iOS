//
//  SearchRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

final class SearchRepositoryImpl: SearchRepository {
    private let datasource: SearchDataSource
    
    init(datasource: SearchDataSource) {
        self.datasource = datasource
    }
    
    func fetchRecentSearchTags() -> [SearchTagEntity] {
        return datasource.fetchRecentSearchTags()
    }
    
    func fetchRecommendedNews() -> [NewsEntity] {
        return datasource.fetchRecommendedNews()
    }
    
    func fetchPosts() -> [PostEntity] {
        return datasource.fetchPosts()
    }
}
