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
    func fetchHistoryDetail(historyId: Int64) async throws -> HistoryDetailDTO
    func fetchClothTags(historyImageId: Int64) async throws -> [ClothTagDTO]
}

// MARK: - History Detail DTO

struct HistoryDetailDTO {
    let memberId: Int64
    let profileImageUrl: String?
    let nickname: String?
    let images: [HistoryImageDTO]
    let likeCount: Int64
    let commentCount: Int64
    let historyDate: String?
    let situationId: Int64?
    let situationName: String?
    let content: String?
    let hashtags: [String]?
    let styles: [HistoryStyleDTO]
}

struct HistoryImageDTO {
    let imageId: Int64
    let imageUrl: String
}

struct HistoryStyleDTO {
    let styleId: Int64
    let styleName: String
}

struct ClothTagDTO {
    let clothId: Int64
    let name: String?
    let brand: String?
    let clothImageUrl: String?
    let locationX: Double
    let locationY: Double
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

    // MARK: - Fetch History Detail

    func fetchHistoryDetail(historyId: Int64) async throws -> HistoryDetailDTO {
        let input = Operations.History_getHistoryDetails.Input(
            path: .init(historyId: historyId)
        )

        let response = try await client.History_getHistoryDetails(input)

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseDailyHistoryResponse.self,
                from: data
            )

            guard let result = decoded.result else {
                throw HistoryAPIError.noData
            }

            return HistoryDetailDTO(
                memberId: result.memberId ?? 0,
                profileImageUrl: result.profileImageUrl,
                nickname: result.nickname,
                images: result.images?.compactMap { img in
                    guard let imageUrl = img.imageUrl else { return nil }
                    return HistoryImageDTO(
                        imageId: img.imageId ?? 0,
                        imageUrl: imageUrl
                    )
                } ?? [],
                likeCount: result.likeCount ?? 0,
                commentCount: result.commentCount ?? 0,
                historyDate: result.historyDate,
                situationId: result.situationId,
                situationName: result.situationName,
                content: result.content,
                hashtags: result.hashtags?.compactMap { $0 as? String },
                styles: result.styles?.compactMap { style in
                    guard let styleId = style.styleId, let styleName = style.styleName else { return nil }
                    return HistoryStyleDTO(styleId: styleId, styleName: styleName)
                } ?? []
            )

        case .undocumented(statusCode: let code, _):
            throw HistoryAPIError.serverError(statusCode: code)
        }
    }

    // MARK: - Fetch Cloth Tags

    func fetchClothTags(historyImageId: Int64) async throws -> [ClothTagDTO] {
        let input = Operations.History_getHistoryClothTags.Input(
            path: .init(historyImageId: historyImageId)
        )

        let response = try await client.History_getHistoryClothTags(input)

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseHistoryClothTagListResponse.self,
                from: data
            )

            guard let payloads = decoded.result?.payloads else {
                throw HistoryAPIError.noData
            }

            return payloads.compactMap { tag in
                guard let clothId = tag.clothId,
                      let locationX = tag.locationX,
                      let locationY = tag.locationY else {
                    return nil
                }
                return ClothTagDTO(
                    clothId: clothId,
                    name: tag.name,
                    brand: tag.brand,
                    clothImageUrl: tag.clothImageUrl,
                    locationX: locationX,
                    locationY: locationY
                )
            }

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
