//
//  SearchUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import CodiveAPI

final class SearchUseCase {
    // MARK: - Properties
    private let repository: SearchRepository
    
    // MARK: - Initializer
    init(repository: SearchRepository) {
        self.repository = repository
    }
    
    // MARK: - Fetch Methods

    /// 검색 탭 기록 추천
    func fetchSearchRecommendation() async throws -> [SearchRecommendationEntity] {
        return try await repository.fetchSearchRecommendation()
    }

    /// 유저 검색
    func fetchSearchMembers(
        keyword: String,
        page: Int64,
        size: Int32
    ) async throws -> (content: [SearchMembersEntity], isLast: Bool) {
        return try await repository.fetchSearchMembers(keyword: keyword, page: page, size: size)
    }

    /// 기록 검색
    func fetchSearchHistories(
        keyword: String,
        page: Int64,
        size: Int32,
        sort: Operations.Search_searchHistoryByHashtagsAndCategories.Input.Query.sortPayload?
    ) async throws -> (content: [SearchHistoriesEntity], isLast: Bool) {
        return try await repository.fetchSearchHistories(keyword: keyword, page: page, size: size, sort: sort)
    }

    /// 전체 유저 검색 엔진 삭제(개발용)
    func fetchSearchMembersUnsyncAll() async throws {
        try await repository.fetchSearchMembersUnsyncAll()
    }

    /// 전체 유저 검색 엔진 동기화(개발용)
    func fetchSearchMembersSyncAll() async throws {
        try await repository.fetchSearchMembersSyncAll()
    }

    /// 전체 기록 검색 엔진 삭제(개발용)
    func fetchSearchHistoryUnsyncAll() async throws {
        try await repository.fetchSearchHistoryUnsyncAll()
    }

    /// 전체 기록 검색 엔진 동기화(개발용)
    func fetchSearchHistorySyncAll() async throws {
        try await repository.fetchSearchHistorySyncAll()
    }
}

extension SearchUseCase {
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
