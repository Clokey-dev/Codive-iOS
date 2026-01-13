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
    func checkAuthStatus() async -> AuthStatusResult
    func reissueTokens(refreshToken: String) async -> Result<TokenPair, AuthError>
    func renewDeviceToken(deviceToken: String) async -> Result<Void, AuthError>
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
        // CodiveAPI Client 생성 with AuthMiddleware
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = Self.createJSONDecoder()
    }

    private static func createJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // 방법 1: ISO8601DateFormatter (표준 형식)
            let formatter1 = ISO8601DateFormatter()
            formatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter1.date(from: dateString) { return date }

            let formatter2 = ISO8601DateFormatter()
            formatter2.formatOptions = [.withInternetDateTime]
            if let date = formatter2.date(from: dateString) { return date }

            // 방법 2: DateFormatter로 나노초 포함 형식 처리
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            // 나노초 형식 (소수점 이하 자릿수 다양)
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS",  // 9자리
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS",   // 8자리
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS",    // 7자리
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",     // 6자리
                "yyyy-MM-dd'T'HH:mm:ss.SSS",        // 3자리
                "yyyy-MM-dd'T'HH:mm:ss"             // 소수점 없음
            ]

            for format in formats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: dateString) { return date }
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "날짜 파싱 실패: \(dateString)")
        }
        return decoder
    }

    func checkAuthStatus() async -> AuthStatusResult {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [AuthAPI] checkAuthStatus 호출")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        do {
            // API 호출
            let response = try await client.Auth_getUserStatus(
                Operations.Auth_getUserStatus.Input()
            )

            // 응답 처리
            switch response {
            case .ok(let okResponse):
                // Body 추출
                let httpBody = try okResponse.body.any
                let data = try await Data(collecting: httpBody, upTo: .max)

                // 🔍 디버그: 원본 응답 출력
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📩 [AuthAPI] 응답 원본:")
                    print(jsonString)
                }

                // JSON 디코딩 (커스텀 디코더 사용)
                do {
                    let apiResponse = try jsonDecoder.decode(
                        Components.Schemas.BaseResponseUserStatusResponse.self,
                        from: data
                    )

                    print("✅ [AuthAPI] 디코딩 성공")

                    // registerStatus 확인
                    guard let result = apiResponse.result,
                          let registerStatus = result.registerStatus else {
                        print("❌ [AuthAPI] result 또는 registerStatus 없음")
                        return .failure(.networkError("회원 상태 정보 없음"))
                    }

                    print("📋 [AuthAPI] registerStatus: \(registerStatus)")

                    // RegisterStatus 변환
                    switch registerStatus {
                    case .NOT_AGREED:
                        return .success(.notAgreed)
                    case .REGISTERED:
                        return .success(.registered)
                    }
                } catch {
                    print("❌ [AuthAPI] 디코딩 실패: \(error)")
                    return .failure(.networkError(error.localizedDescription))
                }

            case .undocumented(statusCode: let statusCode, _):
                print("❌ [AuthAPI] undocumented 응답: \(statusCode)")
                return .failure(.networkError("예상치 못한 응답 코드: \(statusCode)"))
            }

        } catch {
            print("❌ [AuthAPI] 네트워크 에러: \(error)")
            return .failure(.networkError(error.localizedDescription))
        }
    }

    // MARK: - Token Reissue

    func reissueTokens(refreshToken: String) async -> Result<TokenPair, AuthError> {
        print("🔄 [AuthAPI] 토큰 재발급 요청")

        do {
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
                    print("❌ [AuthAPI] 토큰 재발급 응답 파싱 실패")
                    return .failure(.networkError("토큰 재발급 응답 파싱 실패"))
                }

                print("✅ [AuthAPI] 토큰 재발급 성공")
                return .success(TokenPair(accessToken: accessToken, refreshToken: newRefreshToken))

            case .undocumented(statusCode: let statusCode, _):
                print("❌ [AuthAPI] 토큰 재발급 실패: \(statusCode)")
                return .failure(.networkError("토큰 재발급 실패: \(statusCode)"))
            }

        } catch {
            print("❌ [AuthAPI] 토큰 재발급 에러: \(error)")
            return .failure(.networkError(error.localizedDescription))
        }
    }

    // MARK: - Device Token

    func renewDeviceToken(deviceToken: String) async -> Result<Void, AuthError> {
        print("📱 [AuthAPI] 디바이스 토큰 갱신 요청")

        do {
            let requestBody = Components.Schemas.DeviceTokenRenewRequest(deviceToken: deviceToken)
            let input = Operations.Auth_renewDeviceToken.Input(body: .json(requestBody))
            let response = try await client.Auth_renewDeviceToken(input)

            switch response {
            case .ok:
                print("✅ [AuthAPI] 디바이스 토큰 갱신 성공")
                return .success(())

            case .undocumented(statusCode: let statusCode, _):
                print("❌ [AuthAPI] 디바이스 토큰 갱신 실패: \(statusCode)")
                return .failure(.networkError("디바이스 토큰 갱신 실패: \(statusCode)"))
            }

        } catch {
            print("❌ [AuthAPI] 디바이스 토큰 갱신 에러: \(error)")
            return .failure(.networkError(error.localizedDescription))
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
