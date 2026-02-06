//
//  SearchAPIService.swift
//  Codive
//
//  Created by 한금준 on 1/27/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

// MARK: - Search API Service Protocol

protocol SearchAPIServiceProtocol {
    /// 검색 탭 기록 추천
    func fetchSearchRecommendation() async throws -> [SearchRecommendationResponseDTO]

    /// 유저 검색
    func searchUsers(keyword: String, page: Int64, size: Int32) async throws -> SearchUserResult

    /// 기록 검색
    func searchHistories(keyword: String, page: Int64, size: Int32, sort: String?) async throws -> SearchHistoryResult
}

struct SearchUserResult {
    let users: [SimpleUser]
    let isLast: Bool
}

struct SearchHistoryResult {
    let posts: [PostEntity]
    let isLast: Bool
}

final class SearchAPIService: SearchAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }
}

extension SearchAPIService {
    func fetchSearchRecommendation() async throws -> [SearchRecommendationResponseDTO] {
        let input = Operations.Search_recommendInSearching.Input()
        
        let response = try await client.Search_recommendInSearching(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseListSearchingRecommendResponse.self, from: data)
            
            let items = decoded.result ?? []

            return items.map { item in
                SearchRecommendationResponseDTO(
                    historyId: item.historyId ?? 0,
                    memberId: item.memberId ?? 0,
                    recommendType: item.recommendType ?? "",
                    title: item.title ?? "",
                    subTitle: item.subTitle ?? "",
                    imageUrl: item.imageUrl ?? ""
                )
            }
            
        case .undocumented(statusCode: let code, _):
            throw SearchAPIError.serverError(statusCode: code, message: "검색 탭 기록 추천 조회 실패")
        }
    }
}

extension SearchAPIService {
    func searchUsers(keyword: String, page: Int64, size: Int32) async throws -> SearchUserResult {
        let input = Operations.Search_searchUserByNickname.Input(
            query: .init(
                keyword: keyword,
                page: page,
                size: size
            )
        )

        let response = try await client.Search_searchUserByNickname(input)

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
                    handle: member.nickname ?? "",
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
