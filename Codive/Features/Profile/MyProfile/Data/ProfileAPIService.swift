//
//  ProfileAPIService.swift
//  Codive
//
//  Created by 황상환 on 1/25/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

// MARK: - Profile API Service Protocol

protocol ProfileAPIServiceProtocol {
    func fetchMyProfile() async throws -> MyProfileInfo
    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult
    func updateProfile(nickname: String, bio: String, isPublic: Bool, currentImageUrl: String?) async throws -> MyProfileInfo
    func checkNicknameDuplicate(nickname: String) async throws -> Bool
    func uploadProfileImage(_ imageData: Data) async throws -> String
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

    func updateProfile(nickname: String, bio: String, isPublic: Bool, currentImageUrl: String?) async throws -> MyProfileInfo {
        let visibility: Components.Schemas.ProfileUpdateRequest.visibilityPayload = isPublic ? .PUBLIC : .PRIVATE

        let requestBody = Components.Schemas.ProfileUpdateRequest(
            nickname: nickname,
            bio: bio,
            visibility: visibility,
            profileImageUrl: currentImageUrl ?? ""
        )

        let response = try await client.Member_updateProfile(
            .init(body: .json(requestBody))
        )

        switch response {
        case .ok:
            // 204 응답은 result가 없으므로, 수정된 정보를 다시 fetch
            return try await fetchMyProfile()

        case .undocumented(statusCode: let code, _):
            throw ProfileAPIError.serverError(statusCode: code, message: "프로필 수정 실패 (상태코드: \(code))")
        }
    }

    func checkNicknameDuplicate(nickname: String) async throws -> Bool {
        let requestBody = Components.Schemas.DuplicatedIdCheckRequest(nickname: nickname)

        let response = try await client.Member_checkDuplicateNickname(
            .init(body: .json(requestBody))
        )

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            let apiResponse = try jsonDecoder.decode(
                Components.Schemas.BaseResponseDuplicatedIdCheckResponse.self,
                from: data
            )

            // result.duplicated가 true면 중복된 것 (사용 불가)
            return apiResponse.result?.duplicated ?? false

        case .undocumented(statusCode: let code, _):
            throw ProfileAPIError.serverError(statusCode: code, message: "닉네임 중복확인 실패 (상태코드: \(code))")
        }
    }

    func uploadProfileImage(_ imageData: Data) async throws -> String {
        let md5Hash = calculateMD5(from: imageData)
        let uploadPayload = Components.Schemas.ClothImagesUploadRequestPayload(fileExtension: .JPEG, md5Hashes: md5Hash)
        let requestBody = Components.Schemas.ClothImagesUploadRequest(payloads: [uploadPayload])

        let response = try await client.ClothAi_getClothUploadPresignedUrl(
            .init(body: .json(requestBody))
        )

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            let apiResponse = try jsonDecoder.decode(
                Components.Schemas.BaseResponseClothImagesPresignedUrlResponse.self,
                from: data
            )

            guard let urls = apiResponse.result?.urls, !urls.isEmpty else {
                throw ProfileAPIError.invalidResponse
            }

            let presignedUrl = urls[0]

            // S3에 직접 업로드
            try await uploadImageToS3(presignedUrl: presignedUrl, imageData: imageData, contentMD5: md5Hash)

            return extractFinalUrl(from: presignedUrl)

        case .undocumented(statusCode: let code, _):
            throw ProfileAPIError.serverError(statusCode: code, message: "이미지 업로드 실패 (상태코드: \(code))")
        }
    }

    private func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws {
        guard let url = URL(string: presignedUrl) else {
            throw ProfileAPIError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue(contentMD5, forHTTPHeaderField: "Content-MD5")
        request.httpBody = imageData

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProfileAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw ProfileAPIError.s3UploadFailed(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - Private Helpers

private extension ProfileAPIService {
    func calculateMD5(from data: Data) -> String {
        let digest = Insecure.MD5.hash(data: data)
        return Data(digest).base64EncodedString()
    }

    func extractFinalUrl(from presignedUrl: String) -> String {
        guard let url = URL(string: presignedUrl),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return presignedUrl
        }
        components.query = nil
        return components.string ?? presignedUrl
    }
}

// MARK: - Profile API Error

enum ProfileAPIError: LocalizedError {
    case serverError(statusCode: Int, message: String)
    case invalidResponse
    case invalidUrl
    case s3UploadFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .serverError(let statusCode, let message):
            return "서버 오류 (\(statusCode)): \(message)"
        case .invalidResponse:
            return "올바르지 않은 응답 형식입니다"
        case .invalidUrl:
            return "유효하지 않은 URL입니다"
        case .s3UploadFailed(let statusCode):
            return "S3 업로드 실패 (상태 코드: \(statusCode))"
        }
    }
}
