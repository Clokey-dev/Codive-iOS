//
//  SearchDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import Foundation
import CodiveAPI

protocol SearchDataSourceProtocol {
    /// 검색 탭 기록 추천
    func fetchSearchRecommendation() async throws -> [SearchRecommendationResponseDTO]
}

final class SearchDataSource: SearchDataSourceProtocol {
    private let apiService: SearchAPIServiceProtocol
    
    // MARK: - Initializer
    init(
        apiService: SearchAPIServiceProtocol = SearchAPIService()
    ) {
        self.apiService = apiService
    }
    
    /// 검색 탭 기록 추천
    func fetchSearchRecommendation() async throws -> [SearchRecommendationResponseDTO] {
        return try await apiService.fetchSearchRecommendation()
    }
}

extension SearchDataSource {
    func fetchPosts(query: String, sort: String?) async throws -> [PostEntity] {
        let sortParam = sort == "인기순" ? "POPULAR" : (sort == "최신순" ? "LATEST" : nil)
        let result = try await apiService.searchHistories(
            keyword: query,
            page: 0,
            size: 10,
            sort: sortParam
        )
        return result.posts
    }

    // MARK: - Fetch Methods (계정용 추가)

    /// 검색어를 기준으로 유저 목록을 API로 검색
    func fetchUsers(query: String) async throws -> [SimpleUser] {
        let result = try await apiService.searchUsers(
            keyword: query,
            page: 0,
            size: 10
        )
        return result.users
    }
}
