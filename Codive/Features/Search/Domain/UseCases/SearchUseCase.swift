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

    func fetchPosts(query: String, sort: String?) async throws -> [PostEntity] {
        return try await repository.fetchPosts(query: query, sort: sort)
    }

    func fetchUsers(query: String) async throws -> [SimpleUser] {
        return try await repository.fetchUsers(query: query)
    }
}
