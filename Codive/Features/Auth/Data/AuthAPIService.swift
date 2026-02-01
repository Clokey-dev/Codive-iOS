//
//  AuthAPIService.swift
//  Codive
//
//  Created by 황상환 on 1/4/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - Auth API Service Protocol
protocol AuthAPIServiceProtocol {
    func checkAuthStatus() async throws -> RegisterStatus
    func reissueTokens(refreshToken: String) async throws -> TokenPair
    func renewDeviceToken(deviceToken: String) async throws
}

// MARK: - Token Pair
struct TokenPair {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Auth API Service Implementation
final class AuthAPIService: AuthAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
        
        /// 액세스 토큰 확인 하기
#if DEBUG
do {
    let token = try KeychainManager.shared.getAccessToken()
    print("🔑 Current Access Token:", token)
} catch {
    print("❌ Access Token 없음:", error.localizedDescription)
}
#endif
    }

    func checkAuthStatus() async throws -> RegisterStatus {
        let response = try await client.Auth_getUserStatus(
            Operations.Auth_getUserStatus.Input()
        )

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)

            let apiResponse = try jsonDecoder.decode(
                Components.Schemas.BaseResponseUserStatusResponse.self,
                from: data
            )

            guard let result = apiResponse.result,
                  let registerStatus = result.registerStatus else {
                throw AuthError.networkError("회원 상태 정보 없음")
            }

            switch registerStatus {
            case .NOT_AGREED:
                return .notAgreed
            case .REGISTERED:
                return .registered
            }

        case .undocumented(statusCode: let statusCode, _):
            throw AuthError.networkError("예상치 못한 응답 코드: \(statusCode)")
        }
    }

    // MARK: - Token Reissue

    func reissueTokens(refreshToken: String) async throws -> TokenPair {
        let requestBody = Components.Schemas.TokenReissueRequest(refreshToken: refreshToken)
        let input = Operations.Auth_reissueTokens.Input(body: .json(requestBody))
        let response = try await client.Auth_reissueTokens(input)

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)

            let apiResponse = try jsonDecoder.decode(TokenReissueResponse.self, from: data)

            guard let result = apiResponse.result,
                  let accessToken = result.accessToken,
                  let newRefreshToken = result.refreshToken else {
                throw AuthError.networkError("토큰 재발급 응답 파싱 실패")
            }

            return TokenPair(accessToken: accessToken, refreshToken: newRefreshToken)

        case .undocumented(statusCode: let statusCode, _):
            throw AuthError.networkError("토큰 재발급 실패: \(statusCode)")
        }
    }

    // MARK: - Device Token

    func renewDeviceToken(deviceToken: String) async throws {
        let requestBody = Components.Schemas.DeviceTokenRenewRequest(deviceToken: deviceToken)
        let input = Operations.Auth_renewDeviceToken.Input(body: .json(requestBody))
        let response = try await client.Auth_renewDeviceToken(input)

        switch response {
        case .ok:
            return

        case .undocumented(statusCode: let statusCode, _):
            throw AuthError.networkError("디바이스 토큰 갱신 실패: \(statusCode)")
        }
    }
}

// MARK: - Custom Response Types

private struct TokenReissueResponse: Decodable {
    let isSuccess: Bool?
    let code: String?
    let message: String?
    let result: TokenResult?

    struct TokenResult: Decodable {
        let accessToken: String?
        let refreshToken: String?
    }
}
