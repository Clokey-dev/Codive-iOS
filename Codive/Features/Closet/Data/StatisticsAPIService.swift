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
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }

    func checkStatisticsCondition() async throws -> Bool {
        let input = Operations.Statistics_checkStatisticsCondition.Input()
        let response = try await client.Statistics_checkStatisticsCondition(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseStatisticsCheckConditionResponse.self,
                from: data
            )
            return decoded.result?.canAggregate ?? false

        case .undocumented(statusCode: let code, _):
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
