//
//  SearchRepository.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import Foundation
import CodiveAPI

protocol SearchRepository {
    func fetchUserName() -> SearchEntity
    func fetchRecentSearchTags() -> [SearchTagEntity]
    func fetchRecommendedNews() -> [NewsEntity]

    /// 검색 탭 기록 추천
    func fetchSearchRecommendation() async throws -> [SearchRecommendationEntity]

    /// 기록 검색
    func fetchPosts(query: String, sort: String?) async throws -> [PostEntity]

    /// 유저 검색
    func fetchUsers(query: String) async throws -> [SimpleUser]
}
