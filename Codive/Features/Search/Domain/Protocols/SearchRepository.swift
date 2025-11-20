//
//  SearchRepository.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

protocol SearchRepository {
    func fetchUserName() -> SearchEntity
    func fetchRecentSearchTags() -> [SearchTagEntity]
    func fetchRecommendedNews() -> [NewsEntity]
    func fetchPosts(query: String) -> [PostEntity]
}
