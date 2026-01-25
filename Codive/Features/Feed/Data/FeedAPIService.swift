//
//  FeedAPIService.swift
//  Codive
//
//  Created by Gemini on 1/19/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - FeedAPIService Protocol

protocol FeedAPIServiceProtocol {
    func fetchFeeds(
        cursor: String?,
        size: Int32,
        styleIds: [Int64]?,
        situationIds: [Int64]?,
        followScope: FeedFollowScope
    ) async throws -> FeedListResult
}

// MARK: - Supporting Types

enum FeedFollowScope {
    case all
    case following

    var apiValue: Operations.Feed_getFeeds.Input.Query.followScopePayload {
        switch self {
        case .all: return .ALL
        case .following: return .FOLLOWING
        }
    }
}

struct FeedListResult {
    let feeds: [FeedItemDTO]
    let nextCursor: String?
    let hasNext: Bool
}

struct FeedItemDTO {
    let feedId: Int64
    let imageUrl: String?
    let isLiked: Bool?
    let createdAt: Date?
    let author: FeedAuthorDTO
}

struct FeedAuthorDTO {
    let memberId: Int64
    let clokeyId: String?
    let profileImageUrl: String?
    let isFollowing: Bool?
}

// MARK: - FeedAPIService Implementation

final class FeedAPIService: FeedAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }
}

// MARK: - Fetch Feeds

extension FeedAPIService {

    func fetchFeeds(
        cursor: String?,
        size: Int32,
        styleIds: [Int64]?,
        situationIds: [Int64]?,
        followScope: FeedFollowScope
    ) async throws -> FeedListResult {

        let styleIdsStr = styleIds?.map(String.init).joined(separator: ",")
        let situationIdsStr = situationIds?.map(String.init).joined(separator: ",")

        let input = Operations.Feed_getFeeds.Input(
            query: .init(
                followScope: followScope.apiValue,
                styleIds: styleIdsStr,
                situationIds: situationIdsStr,
                size: size,
                cursor: cursor
            )
        )

        let response = try await client.Feed_getFeeds(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseFeedListResponse.self,
                from: data
            )

            let items = decoded.result?.items ?? []
            let feeds: [FeedItemDTO] = items.map { item in
                FeedItemDTO(
                    feedId: item.feedId ?? 0,
                    imageUrl: item.imageUrl,
                    isLiked: item.isLiked,
                    createdAt: item.createdAt,
                    author: FeedAuthorDTO(
                        memberId: item.author?.memberId ?? 0,
                        clokeyId: item.author?.clokeyId,
                        profileImageUrl: item.author?.profileImageUrl,
                        isFollowing: item.author?.isFollowing
                    )
                )
            }

            return FeedListResult(
                feeds: feeds,
                nextCursor: decoded.result?.nextCursor,
                hasNext: decoded.result?.hasNext ?? false
            )

        case .undocumented(statusCode: let code, _):
            throw FeedAPIError.serverError(statusCode: code, message: "피드 목록 조회 실패")
        }
    }
}

// MARK: - FeedAPIError

enum FeedAPIError: LocalizedError {
    case serverError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .serverError(let statusCode, let message):
            return "서버 오류 (\(statusCode)): \(message)"
        }
    }
}