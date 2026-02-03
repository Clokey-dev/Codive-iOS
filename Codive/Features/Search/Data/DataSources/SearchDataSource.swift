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
    
    /// 유저 검색
    func fetchSearchMembers(keyword: String, page: Int64, size: Int32) async throws -> SearchUserResponseDTO
    
    /// 전체 유저 검색 엔진 삭제(개발용)
    func fetchSearchMembersUnsyncAll() async throws
    
    /// 전체 유저 검색 엔진 동기화(개발용)
    func fetchSearchMembersSyncAll() async throws
    
    /// 기록 검색
    func fetchSearchHistories(
        keyword: String,
        page: Int64,
        size: Int32,
        sort: Operations.Search_searchHistoryByHashtagsAndCategories.Input.Query.sortPayload?
    ) async throws -> SearchHistoryResponseDTO
    
    /// 전체 기록 검색 엔진 삭제(개발용)
    func fetchSearchHistoryUnsyncAll() async throws
    
    /// 전체 기록 검색 엔진 동기화(개발용)
    func fetchSearchHistorySyncAll() async throws
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
    
    /// 유저 검색
    func fetchSearchMembers(keyword: String, page: Int64, size: Int32
    ) async throws -> SearchUserResponseDTO {
        return try await apiService.fetchSearchMembers(
            keyword: keyword,
            page: page,
            size: size
        )
    }
    
    /// 전체 유저 검색 엔진 삭제(개발용)
    func fetchSearchMembersUnsyncAll() async throws {
        try await apiService.fetchSearchMembersUnsyncAll()
    }
    
    /// 전체 유저 검색 엔진 동기화(개발용)
    func fetchSearchMembersSyncAll() async throws {
        try await apiService.fetchSearchMembersSyncAll()
    }
    
    /// 기록 검색
    func fetchSearchHistories(
        keyword: String,
        page: Int64,
        size: Int32,
        sort: Operations.Search_searchHistoryByHashtagsAndCategories.Input.Query.sortPayload?
    ) async throws -> SearchHistoryResponseDTO {
        return try await apiService.fetchSearchHistories(
            keyword: keyword,
            page: page,
            size: size,
            sort: sort
        )
    }
    
    /// 전체 기록 검색 엔진 삭제(개발용)
    func fetchSearchHistoryUnsyncAll() async throws {
        try await apiService.fetchSearchHistoryUnsyncAll()
    }
    
    /// 전체 기록 검색 엔진 동기화(개발용)
    func fetchSearchHistorySyncAll() async throws {
        try await apiService.fetchSearchHistorySyncAll()
    }
}

extension SearchDataSource {
    // MARK: - Fetch Methods (기존)

    func fetchUserName() -> SearchEntity {
        return SearchEntity(username: "코디브")
    }

    func fetchRecentSearchTags() -> [SearchTagEntity] {
        return [
            SearchTagEntity(id: 1, text: "겨울"),
            SearchTagEntity(id: 2, text: "한강룩"),
            SearchTagEntity(id: 3, text: "한금준"),
            SearchTagEntity(id: 4, text: "패션이 좋아요")
        ]
    }

    func fetchRecommendedNews() -> [NewsEntity] {
        return [
            NewsEntity(
                id: 1,
                imageUrl: "https://picsum.photos/273/300",
                title: "개강룩!\n첫 인상 잡수 올리기"
            ),
            NewsEntity(
                id: 2,
                imageUrl: "https://picsum.photos/273/301",
                title: "가을 자켓\n오늘의 코디"
            )
        ]
    }

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
