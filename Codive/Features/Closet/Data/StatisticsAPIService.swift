//
//  StatisticsAPIService.swift
//  Codive
//
//  Created by 황상환 on 2/26/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - StatisticsAPIService Protocol

protocol StatisticsAPIServiceProtocol {
    func checkStatisticsCondition() async throws -> Bool
}

// MARK: - StatisticsAPIService Implementation

final class StatisticsAPIService: StatisticsAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createConfiguredClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }

    func checkStatisticsCondition() async throws -> Bool {
        let input = Operations.Statistics_checkStatisticsCondition.Input()
        #if DEBUG
        print("[StatisticsAPI] 통계 조건 확인 요청 시작")
        #endif
        let response = try await client.Statistics_checkStatisticsCondition(input)

        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json
            #if DEBUG
            print("[StatisticsAPI] 응답 성공 - isSuccess: \(decoded.isSuccess ?? false), code: \(decoded.code ?? "nil"), message: \(decoded.message ?? "nil")")
            print("[StatisticsAPI] canAggregate: \(decoded.result?.canAggregate ?? false)")
            #endif
            return decoded.result?.canAggregate ?? false

        case .undocumented(statusCode: let code, _):
            #if DEBUG
            print("[StatisticsAPI] 응답 실패 - statusCode: \(code)")
            #endif
            throw StatisticsAPIError.serverError(statusCode: code, message: "통계 조건 확인 실패")
        }
    }
}

// MARK: - StatisticsAPIError

enum StatisticsAPIError: LocalizedError {
    case serverError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .serverError(_, let message):
            return message
        }
    }
}
