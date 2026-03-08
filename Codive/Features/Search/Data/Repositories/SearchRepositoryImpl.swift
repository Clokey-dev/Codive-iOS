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

    func fetchPosts(query: String, sort: String?) async throws -> [PostEntity] {
        return try await datasource.fetchPosts(query: query, sort: sort)
    }

    func fetchUsers(query: String) async throws -> [SimpleUser] {
        return try await datasource.fetchUsers(query: query)
    }
}
