//
//  SearchAPIService.swift
//  Codive
//
//  Created by Claude on 1/23/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - Search API Service Protocol

protocol SearchAPIServiceProtocol {
    func searchUsers(keyword: String, page: Int64, size: Int32) async throws -> SearchUserResult
    func searchHistories(keyword: String, page: Int64, size: Int32, sort: String?) async throws -> SearchHistoryResult
}

// MARK: - Supporting Types

struct SearchUserResult {
    let users: [SimpleUser]
    let isLast: Bool
}

struct SearchHistoryResult {
    let posts: [PostEntity]
    let isLast: Bool
}

// MARK: - Search API Service Implementation

final class SearchAPIService: SearchAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }

    // MARK: - Search Users

    func searchUsers(keyword: String, page: Int64, size: Int32) async throws -> SearchUserResult {
        let input = Operations.Search_searchUserByClokeyIdAndNickname.Input(
            query: .init(
                keyword: keyword,
                page: page,
                size: size
            )
        )

        let response = try await client.Search_searchUserByClokeyIdAndNickname(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseSliceResponseSearchedMemberResponse.self,
                from: data
            )

            let members = decoded.result?.content ?? []
            let users: [SimpleUser] = members.compactMap { member -> SimpleUser? in
                guard let userId = member.memberId else { return nil }
                return SimpleUser(
                    userId: Int(userId),
                    nickname: member.nickname ?? "",
                    handle: member.clokeyId ?? "",
                    avatarURL: member.profileImageUrl.flatMap { URL(string: $0) }
                )
            }

            return SearchUserResult(
                users: users,
                isLast: decoded.result?.isLast ?? true
            )

        case .undocumented(statusCode: let code, _):
            throw SearchAPIError.serverError(statusCode: code, message: "유저 검색 실패")
        }
    }

    // MARK: - Search Histories

    func searchHistories(keyword: String, page: Int64, size: Int32, sort: String?) async throws -> SearchHistoryResult {
        let sortPayload = sort.flatMap { sortStr in
            Operations.Search_searchHistoryByHashtagsAndCategories.Input.Query.sortPayload(rawValue: sortStr)
        }

        let input = Operations.Search_searchHistoryByHashtagsAndCategories.Input(
            query: .init(
                keyword: keyword,
                page: page,
                size: size,
                sort: sortPayload
            )
        )

        let response = try await client.Search_searchHistoryByHashtagsAndCategories(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseSliceResponseSearchedHistoryResponse.self,
                from: data
            )

            let histories = decoded.result?.content ?? []
            let posts: [PostEntity] = histories.compactMap { history -> PostEntity? in
                guard let historyId = history.historyId else { return nil }
                return PostEntity(
                    id: Int(historyId),
                    postImageUrl: history.historyImageUrl,
                    profileImageUrl: history.profileImageUrl,
                    nickname: history.nickname ?? "",
                    likes: 0,
                    date: Date(),
                    description: nil
                )
            }

            return SearchHistoryResult(
                posts: posts,
                isLast: decoded.result?.isLast ?? true
            )

        case .undocumented(statusCode: let code, _):
            throw SearchAPIError.serverError(statusCode: code, message: "해시태그 검색 실패")
        }
    }
}

// MARK: - Search API Error

enum SearchAPIError: LocalizedError {
    case serverError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .serverError(let statusCode, let message):
            return "서버 오류 (\(statusCode)): \(message)"
        }
    }
}
