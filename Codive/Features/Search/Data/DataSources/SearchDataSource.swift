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
    
    func fetchPosts(query: String) -> [PostEntity] {
        let allPosts = getAllPosts()
        
        if query.isEmpty || query == "전체" {
            return allPosts
        }
        
        let lowercasedQuery = query.lowercased()
        
        return allPosts.filter { post in
            let matchNickname = post.nickname.lowercased().contains(lowercasedQuery)
            let matchDescription = post.description?.lowercased().contains(lowercasedQuery) ?? false
            return matchNickname || matchDescription
        }
    }
    
    // MARK: - Fetch Methods (계정용 추가)
    
    /// 검색어를 기준으로 유저 목록을 필터링해서 반환
    func fetchUsers(query: String) -> [SimpleUser] {
        let allUsers = getAllUsers()
        
        // 전체 or 빈 문자열이면 전부 리턴
        if query.isEmpty || query == "전체" {
            return allUsers
        }
        
        let lowercasedQuery = query.lowercased()
        
        return allUsers.filter { user in
            user.nickname.lowercased().contains(lowercasedQuery)
            || user.handle.lowercased().contains(lowercasedQuery)
        }
    }
    
    // MARK: - Private Methods (공통)
    
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
    
    // MARK: - Private Methods (게시글 더미)
    
    private func getAllPosts() -> [PostEntity] {
        return [
            PostEntity(
                id: 1,
                postImageUrl: "https://picsum.photos/id/1018/162/216",
                profileImageUrl: "https://picsum.photos/id/237/28/28",
                nickname: "유저A",
                likes: 150,
                date: createDate(year: 2025, month: 11, day: 19),
                description: "가을 자켓 코디"
            ),
            PostEntity(
                id: 2,
                postImageUrl: "https://picsum.photos/id/1019/162/216",
                profileImageUrl: nil,
                nickname: "유저B",
                likes: 80,
                date: createDate(year: 2025, month: 11, day: 17),
                description: "겨울 드뮤어룩"
            ),
            PostEntity(
                id: 3,
                postImageUrl: "https://picsum.photos/id/1020/162/216",
                profileImageUrl: "https://picsum.photos/id/100/28/28",
                nickname: "유저C",
                likes: 250,
                date: createDate(year: 2025, month: 11, day: 18),
                description: "데일리룩 추천"
            ),
            PostEntity(
                id: 4,
                postImageUrl: "https://picsum.photos/id/1021/162/216",
                profileImageUrl: nil,
                nickname: "유저D",
                likes: 50,
                date: createDate(year: 2025, month: 11, day: 19),
                description: "드뮤어룩 첼시부츠"
            )
        ]
    }
    
    // MARK: - Private Methods (유저 더미)
    
    private func getAllUsers() -> [SimpleUser] {
        return [
            SimpleUser(
                userId: 1,
                nickname: "코디브 공식",
                handle: "@codive_official",
                avatarURL: URL(string: "https://picsum.photos/id/200/80/80")
            ),
            SimpleUser(
                userId: 2,
                nickname: "한금준",
                handle: "@geumjoon",
                avatarURL: URL(string: "https://picsum.photos/id/201/80/80")
            ),
            SimpleUser(
                userId: 3,
                nickname: "드뮤어룩 장인",
                handle: "@demure_master",
                avatarURL: URL(string: "https://picsum.photos/id/202/80/80")
            ),
            SimpleUser(
                userId: 4,
                nickname: "한강러버",
                handle: "@hanriver_lover",
                avatarURL: nil
            )
        ]
    }
}
