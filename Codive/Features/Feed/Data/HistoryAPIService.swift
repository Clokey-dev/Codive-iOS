//
//  HistoryAPIService.swift
//  Codive
//
//  Created by 황상환 on 1/13/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - History API Service Protocol

protocol HistoryAPIServiceProtocol {
    func createHistory(request: HistoryCreateAPIRequest) async throws -> Int64
}

// MARK: - Request Types

struct HistoryCreateAPIRequest {
    let content: String?
    let situationId: Int64
    let styleIds: [Int64]
    let hashtags: [String]
    let payloads: [HistoryImagePayload]
}

struct HistoryImagePayload {
    let imageUrl: String
    let clothTags: [RecordClothTag]
}

// MARK: - History API Service Implementation

final class HistoryAPIService: HistoryAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }

    // MARK: - Create History

    func createHistory(request: HistoryCreateAPIRequest) async throws -> Int64 {
        let payloads = request.payloads.map { payload in
            Components.Schemas.HistoryCreatePayload(
                imageUrl: payload.imageUrl,
                clothTags: payload.clothTags.map { tag in
                    Components.Schemas.ClothTag(
                        clothId: tag.clothId,
                        locationX: tag.locationX,
                        locationY: tag.locationY
                    )
                }
            )
        }

        let hashtagContainers: [OpenAPIRuntime.OpenAPIValueContainer]? = request.hashtags.isEmpty
            ? nil
            : request.hashtags.compactMap { try? OpenAPIRuntime.OpenAPIValueContainer(unvalidatedValue: $0) }

        let requestBody = Components.Schemas.HistoryCreateRequest(
            content: request.content,
            situationId: request.situationId,
            styleIds: request.styleIds,
            hashtags: hashtagContainers,
            payloads: payloads
        )

        let input = Operations.History_createHistory.Input(body: .json(requestBody))
        let response = try await client.History_createHistory(input)

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)
            let decoded = try jsonDecoder.decode(HistoryCreateResponse.self, from: data)

            guard let historyId = decoded.result?.historyId else {
                throw HistoryAPIError.noData
            }

            return historyId

        case .undocumented(statusCode: let code, _):
            throw HistoryAPIError.serverError(statusCode: code)
        }
    }
}

// MARK: - Response Types

private struct HistoryCreateResponse: Decodable {
    let isSuccess: Bool?
    let code: String?
    let message: String?
    let result: HistoryResult?

    struct HistoryResult: Decodable {
        let historyId: Int64?
    }
}

// MARK: - Error

enum HistoryAPIError: LocalizedError {
    case noData
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .noData:
            return "응답 데이터가 없습니다."
        case .serverError(let code):
            return "서버 오류 (\(code))"
        }
    }
}
