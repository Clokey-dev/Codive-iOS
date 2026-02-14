//
//  HistoryAPIService.swift
//  Codive
//
//  Created by 황상환 on 1/13/26.
//

import Foundation
import CryptoKit
import CodiveAPI
import OpenAPIRuntime

// MARK: - History API Service Protocol

protocol HistoryAPIServiceProtocol {
    func createHistory(request: HistoryCreateAPIRequest) async throws -> Int64
    func updateHistory(historyId: Int64, request: HistoryCreateAPIRequest) async throws
    func fetchHistoryDetail(historyId: Int64) async throws -> HistoryDetailDTO
    func fetchClothTags(historyImageId: Int64) async throws -> [ClothTagDTO]
    func fetchMonthlyHistory(memberId: Int64, year: Int32, month: Int32) async throws -> [MonthlyHistoryItemDTO]
    func deleteHistory(historyId: Int64) async throws
    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo]
    func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws
}

// MARK: - History Detail DTO

struct HistoryDetailDTO {
    let memberId: Int64
    let profileImageUrl: String?
    let nickname: String?
    let isMine: Bool
    let images: [HistoryImageDTO]
    let likeCount: Int64
    let commentCount: Int64
    let isLiked: Bool
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

    // MARK: - Create & Update History

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

        case .undocumented(statusCode: let code, let body):
            let errorDetail = await extractErrorDetail(from: body)
            print("❌ Create API Error - Status: \(code), Detail: \(errorDetail)")
            throw HistoryAPIError.serverError(statusCode: code, detail: errorDetail)
        }
    }

    func updateHistory(historyId: Int64, request: HistoryCreateAPIRequest) async throws {
        let payloads = request.payloads.map { payload in
            Components.Schemas.HistoryUpdatePayload(
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

        let requestBody = Components.Schemas.HistoryUpdateRequest(
            content: request.content,
            situationId: request.situationId,
            styleIds: request.styleIds,
            hashtags: hashtagContainers,
            payloads: payloads
        )

        let input = Operations.History_updateHistory.Input(
            path: .init(historyId: historyId),
            body: .json(requestBody)
        )
        let response = try await client.History_updateHistory(input)

        switch response {
        case .ok:
            return

        case .undocumented(statusCode: let code, let body):
            // Try to extract error details from response body
            let errorDetail = await extractErrorDetail(from: body)
            print("❌ Update API Error - Status: \(code), Detail: \(errorDetail)")
            throw HistoryAPIError.serverError(statusCode: code, detail: errorDetail)
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
                isMine: result.isMine ?? false,
                images: result.images?.compactMap { img in
                    guard let imageUrl = img.imageUrl else { return nil }
                    return HistoryImageDTO(
                        imageId: img.imageId ?? 0,
                        imageUrl: imageUrl
                    )
                } ?? [],
                likeCount: result.likeCount ?? 0,
                commentCount: result.commentCount ?? 0,
                isLiked: result.liked ?? false,
                historyDate: result.historyDate,
                situationId: result.situationId,
                situationName: result.situationName,
                content: result.content,
                hashtags: result.hashtags?.compactMap { $0 },
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

    // MARK: - Fetch Monthly History

    func fetchMonthlyHistory(memberId: Int64, year: Int32, month: Int32) async throws -> [MonthlyHistoryItemDTO] {
        let input = Operations.History_getMonthlyHistory.Input(
            path: .init(memberId: memberId),
            query: .init(year: year, month: month)
        )

        let response = try await client.History_getMonthlyHistory(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseMonthlyHistoryResponse.self,
                from: data
            )

            guard let payloads = decoded.result?.payloads else {
                throw HistoryAPIError.noData
            }

            return payloads.compactMap { payload in
                MonthlyHistoryItemDTO(
                    historyId: payload.historyId,
                    firstImageUrl: payload.firstImageUrl,
                    historyDate: payload.historyDate
                )
            }

        case .undocumented(statusCode: let code, _):
            throw HistoryAPIError.serverError(statusCode: code)
        }
    }

    // MARK: - Helper Methods

    private func extractErrorDetail(from payload: UndocumentedPayload) async -> String {
        // The payload contains the error response from the server
        // For now, return a generic message to help with debugging
        // In a real scenario, we would parse the response body for more details
        return "서버에서 요청을 처리할 수 없습니다. 네트워크 상태를 확인해주세요."
    }

    // MARK: - Delete History

    func deleteHistory(historyId: Int64) async throws {
        let input = Operations.History_deleteHistory.Input(
            path: .init(historyId: historyId)
        )

        let response = try await client.History_deleteHistory(input)

        switch response {
        case .ok:
            return

        case .undocumented(statusCode: let code, let body):
            let errorDetail = await extractErrorDetail(from: body)
            print("❌ Delete API Error - Status: \(code), Detail: \(errorDetail)")
            throw HistoryAPIError.serverError(statusCode: code, detail: errorDetail)
        }
    }
}

// MARK: - Presigned URL & S3 Upload

extension HistoryAPIService {

    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo] {
        let payloads = images.map { imageData in
            let md5Hash = calculateMD5(from: imageData)
            return (
                payload: Components.Schemas.HistoryImagesUploadRequestPayload(fileExtension: .JPEG, md5Hashes: md5Hash),
                md5Hash: md5Hash
            )
        }

        let requestBody = Components.Schemas.HistoryImagesUploadRequest(payloads: payloads.map { $0.payload })
        let input = Operations.History_getHistoryUploadPresignedUrl.Input(body: .json(requestBody))
        let response = try await client.History_getHistoryUploadPresignedUrl(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseHistoryImagesPresignedUrlResponse.self, from: data)

            guard let urls = decoded.result?.urls, urls.count == images.count else {
                throw HistoryAPIError.noData
            }

            return zip(urls, payloads).map { url, payloadInfo in
                PresignedUrlInfo(presignedUrl: url, finalUrl: extractFinalUrl(from: url), md5Hash: payloadInfo.md5Hash)
            }

        case .undocumented(statusCode: let code, _):
            throw HistoryAPIError.serverError(statusCode: code, detail: "Presigned URL 발급 실패")
        }
    }

    func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws {
        guard let url = URL(string: presignedUrl) else {
            throw HistoryAPIError.serverError(statusCode: 0, detail: "잘못된 URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue(contentMD5, forHTTPHeaderField: "Content-MD5")
        request.httpBody = imageData

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw HistoryAPIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0, detail: "S3 업로드 실패")
        }
    }

    private func calculateMD5(from data: Data) -> String {
        let digest = Insecure.MD5.hash(data: data)
        return Data(digest).base64EncodedString()
    }

    private func extractFinalUrl(from presignedUrl: String) -> String {
        guard let url = URL(string: presignedUrl),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return presignedUrl
        }
        components.query = nil
        return components.string ?? presignedUrl
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
    case serverError(statusCode: Int, detail: String? = nil)

    var errorDescription: String? {
        switch self {
        case .noData:
            return "응답 데이터가 없습니다."
        case .serverError(let code, let detail):
            if let detail = detail, !detail.isEmpty {
                return "서버 오류 (\(code)): \(detail)"
            }
            return "서버 오류 (\(code))"
        }
    }
}
