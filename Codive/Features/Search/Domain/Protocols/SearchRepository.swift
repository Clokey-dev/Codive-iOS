//
//  SearchRepository.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

protocol SearchRepository {
    func fetchRecentSearchTags() -> [SearchTagEntity]
    func fetchRecommendedNews() -> [NewsEntity]
}
