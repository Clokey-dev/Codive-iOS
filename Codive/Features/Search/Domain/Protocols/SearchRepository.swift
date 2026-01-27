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
    func fetchPosts(query: String) -> [PostEntity]
    func fetchUsers(query: String) -> [SimpleUser]
    
    /// 검색 탭 기록 추천
    func fetchSearchRecommendation() async throws -> [SearchRecommendationEntity]
    
    /// 유저 검색
    func fetchSearchMembers(keyword: String, page: Int64, size: Int32) async throws -> (content: [SearchMembersEntity], isLast: Bool)
    
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
    ) async throws -> (content: [SearchHistoriesEntity], isLast: Bool)
    
    /// 전체 기록 검색 엔진 삭제(개발용)
    func fetchSearchHistoryUnsyncAll() async throws
    
    /// 전체 기록 검색 엔진 동기화(개발용)
    func fetchSearchHistorySyncAll() async throws
}
