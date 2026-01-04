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
}

// MARK: - Auth API Service Implementation
final class AuthAPIService: AuthAPIServiceProtocol {

    private let client: Client

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        // CodiveAPI Client 생성 with AuthMiddleware
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
    }

    func checkAuthStatus() async -> AuthStatusResult {
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

                // JSON 디코딩
                let apiResponse = try JSONDecoder().decode(
                    Components.Schemas.BaseResponseUserStatusResponse.self,
                    from: data
                )

                // registerStatus 확인
                guard let result = apiResponse.result,
                      let registerStatus = result.registerStatus else {
                    return .failure(.networkError("회원 상태 정보 없음"))
                }

                // RegisterStatus 변환
                switch registerStatus {
                case .NOT_AGREED:
                    return .success(.notAgreed)
                case .REGISTERED:
                    return .success(.registered)
                }

            case .undocumented(statusCode: let statusCode, _):
                return .failure(.networkError("예상치 못한 응답 코드: \(statusCode)"))
            }

        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
}
