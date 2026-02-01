//
//  SearchRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import Foundation
import CodiveAPI

final class SearchRepositoryImpl: SearchRepository {
    // MARK: - Properties
    private let datasource: SearchDataSource
    
    // MARK: - Initializer
    init(datasource: SearchDataSource) {
        self.datasource = datasource
    }
    
    /// 검색 탭 기록 추천
    func fetchSearchRecommendation() async throws -> [SearchRecommendationEntity] {
        let dtoList = try await datasource.fetchSearchRecommendation()
        return dtoList.map { $0.toEntity()}
    }
    
    /// 유저 검색
    func fetchSearchMembers(
        keyword: String,
        page: Int64,
        size: Int32
    ) async throws -> (content: [SearchMembersEntity], isLast: Bool) {
        
        let dto = try await datasource.fetchSearchMembers(
            keyword: keyword,
            page: page,
            size: size
        )
        
        return (
            content: dto.content.map { $0.toEntity() },
            isLast: dto.isLast
        )
    }
    
    /// 전체 유저 검색 엔진 삭제(개발용)
    func fetchSearchMembersUnsyncAll() async throws {
        try await datasource.fetchSearchMembersUnsyncAll()
    }
    
    /// 전체 유저 검색 엔진 동기화(개발용)
    func fetchSearchMembersSyncAll() async throws {
        try await datasource.fetchSearchMembersSyncAll()
    }
    
    /// 기록 검색
    func fetchSearchHistories(
        keyword: String,
        page: Int64,
        size: Int32,
        sort: Operations.Search_searchHistoryByHashtagsAndCategories.Input.Query.sortPayload?
    ) async throws -> (content: [SearchHistoriesEntity], isLast: Bool) {
        let dto = try await datasource.fetchSearchHistories(
            keyword: keyword,
            page: page,
            size: size,
            sort: sort
        )
        let entities = dto.content.map { $0.toEntity() }
        return (content: entities, isLast: dto.isLast)
    }
    
    /// 전체 기록 검색 엔진 삭제(개발용)
    func fetchSearchHistoryUnsyncAll() async throws {
        try await datasource.fetchSearchHistoryUnsyncAll()
    }
    
    /// 전체 기록 검색 엔진 동기화(개발용)
    func fetchSearchHistorySyncAll() async throws {
        try await datasource.fetchSearchHistorySyncAll()
    }
}

extension SearchRepositoryImpl {
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
    
    func fetchPosts(query: String, sort: String?) async throws -> [PostEntity] {
        return try await datasource.fetchPosts(query: query, sort: sort)
    }

    func fetchUsers(query: String) async throws -> [SimpleUser] {
        return try await datasource.fetchUsers(query: query)
    }
}
