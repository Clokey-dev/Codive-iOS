//
//  ProfileAPIService.swift
//  Codive
//
//  Created by Claude on 1/25/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - Profile API Service Protocol

protocol ProfileAPIServiceProtocol {
    func fetchMyProfile() async throws -> MyProfileInfo
    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult
}

// MARK: - Supporting Types

struct MyProfileInfo {
    let userId: Int
    let nickname: String
    let displayName: String
    let introduction: String?
    let profileImageUrl: String?
    let followerCount: Int
    let followingCount: Int
}

struct FollowListResult {
    let followers: [SimpleUser]
    let isLast: Bool
}

// MARK: - Profile API Service Implementation

final class ProfileAPIService: ProfileAPIServiceProtocol {
    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }

    func fetchMyProfile() async throws -> MyProfileInfo {
        let response = try await client.Member_getMyInfo()

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            // API 응답을 BaseResponseMemberInfoResponse로 decode
            let apiResponse = try jsonDecoder.decode(
                Components.Schemas.BaseResponseMemberInfoResponse.self,
                from: data
            )

            guard let memberInfo = apiResponse.result else {
                throw ProfileAPIError.invalidResponse
            }

            guard let userId = memberInfo.memberId,
                  let nickname = memberInfo.nickname else {
                throw ProfileAPIError.invalidResponse
            }

            return MyProfileInfo(
                userId: Int(userId),
                nickname: nickname,
                displayName: nickname,
                introduction: memberInfo.bio,
                profileImageUrl: memberInfo.profileImageUrl,
                followerCount: Int(memberInfo.followerCount ?? 0),
                followingCount: Int(memberInfo.followingCount ?? 0)
            )

        case .undocumented(statusCode: let code, _):
            throw ProfileAPIError.serverError(statusCode: code, message: "내 프로필 조회 실패")
        }
    }

    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult {
        let response = try await client.Member_getFollows(
            query: Operations.Member_getFollows.Input.Query(
                memberId: Int64(memberId),
                lastFollowId: lastFollowId,
                isFollowing: isFollowing,
                size: size
            )
        )

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            let apiResponse = try jsonDecoder.decode(
                Components.Schemas.BaseResponseSliceResponseFollowMemberResponse.self,
                from: data
            )

            let members = apiResponse.result?.content ?? []
            let followers: [SimpleUser] = members.compactMap { member -> SimpleUser? in
                guard let userId = member.memberId else { return nil }
                return SimpleUser(
                    userId: Int(userId),
                    nickname: member.nickname ?? "",
                    handle: member.nickname ?? "",
                    avatarURL: member.profileImageUrl.flatMap { URL(string: $0) }
                )
            }

            return FollowListResult(
                followers: followers,
                isLast: apiResponse.result?.isLast ?? true
            )

        case .undocumented(statusCode: let code, _):
            throw ProfileAPIError.serverError(statusCode: code, message: "팔로우 목록 조회 실패")
        }
    }
}

// MARK: - Profile API Error

enum ProfileAPIError: LocalizedError {
    case serverError(statusCode: Int, message: String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .serverError(let statusCode, let message):
            return "서버 오류 (\(statusCode)): \(message)"
        case .invalidResponse:
            return "올바르지 않은 응답 형식입니다"
        }
    }
}
