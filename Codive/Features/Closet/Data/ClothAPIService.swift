//
//  ClothAPIService.swift
//  Codive
//
//  Created by 황상환 on 1/12/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

// MARK: - ClothAPIService Protocol

protocol ClothAPIServiceProtocol {
    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo]
    func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws
    func createClothes(requests: [ClothCreateAPIRequest]) async throws -> [Int64]
    func fetchClothes(lastClothId: Int64?, size: Int32, categoryId: Int64?, seasons: [Season]) async throws -> ClothListResult
    func fetchClothDetails(clothId: Int64) async throws -> ClothDetailResult
    func updateCloth(clothId: Int64, request: ClothUpdateAPIRequest) async throws
    func deleteCloth(clothId: Int64) async throws
}

// MARK: - Supporting Types

struct PresignedUrlInfo {
    let presignedUrl: String
    let finalUrl: String
    let md5Hash: String
}

struct ClothCreateAPIRequest {
    let clothImageUrl: String
    let clothUrl: String?
    let name: String?
    let brand: String?
    let season: Season
    let categoryId: Int64
}

struct ClothListResult {
    let clothes: [ClothListItem]
    let isLast: Bool
}

struct ClothListItem {
    let clothId: Int64
    let imageUrl: String
    let brand: String?
    let name: String?
}

struct ClothDetailResult {
    let clothImageUrl: String
    let parentCategory: String?
    let category: String?
    let name: String?
    let brand: String?
    let clothUrl: String?
}

struct ClothUpdateAPIRequest {
    let clothImageUrl: String?
    let clothUrl: String?
    let name: String?
    let brand: String?
    let season: Season           // API에서 required
    let categoryId: Int64        // API에서 required
}

// MARK: - ClothAPIService Implementation

final class ClothAPIService: ClothAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
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

            let formatter1 = ISO8601DateFormatter()
            formatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter1.date(from: dateString) { return date }

            let formatter2 = ISO8601DateFormatter()
            formatter2.formatOptions = [.withInternetDateTime]
            if let date = formatter2.date(from: dateString) { return date }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = dateFormatter.date(from: dateString) { return date }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "날짜 파싱 실패: \(dateString)")
        }
        return decoder
    }
}

// MARK: - Presigned URL & S3 Upload

extension ClothAPIService {

    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo] {
        let payloads = images.map { imageData in
            let md5Hash = calculateMD5(from: imageData)
            return (
                payload: Components.Schemas.ClothImagesUploadRequestPayload(fileExtension: .JPEG, md5Hashes: md5Hash),
                md5Hash: md5Hash
            )
        }

        let requestBody = Components.Schemas.ClothImagesUploadRequest(payloads: payloads.map { $0.payload })
        let input = Operations.Cloth_getClothUploadPresignedUrl.Input(body: .json(requestBody))
        let response = try await client.Cloth_getClothUploadPresignedUrl(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseClothImagesPresignedUrlResponse.self, from: data)

            guard let urls = decoded.result?.urls, urls.count == images.count else {
                throw ClothAPIError.presignedUrlMismatch
            }

            return zip(urls, payloads).map { url, payloadInfo in
                PresignedUrlInfo(presignedUrl: url, finalUrl: extractFinalUrl(from: url), md5Hash: payloadInfo.md5Hash)
            }

        case .undocumented(statusCode: let code, _):
            throw ClothAPIError.serverError(statusCode: code, message: "Presigned URL 발급 실패")
        }
    }

    func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws {
        guard let url = URL(string: presignedUrl) else {
            throw ClothAPIError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue(contentMD5, forHTTPHeaderField: "Content-MD5")
        request.httpBody = imageData

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClothAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw ClothAPIError.s3UploadFailed(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - Create Clothes

extension ClothAPIService {

    func createClothes(requests: [ClothCreateAPIRequest]) async throws -> [Int64] {
        // 디버그: 요청 데이터 출력
        for (index, req) in requests.enumerated() {
            print("📦 [createClothes] 옷 \(index + 1):")
            print("   - clothImageUrl: \(req.clothImageUrl)")
            print("   - name: \(req.name ?? "nil")")
            print("   - brand: \(req.brand ?? "nil")")
            print("   - season: \(req.season.rawValue)")
            print("   - categoryId: \(req.categoryId)")
        }

        let apiRequests = requests.map { request in
            Components.Schemas.ClothCreateRequest(
                clothImageUrl: request.clothImageUrl,
                clothUrl: request.clothUrl,
                name: request.name,
                brand: request.brand,
                season: mapSeasonToCreateAPI(request.season),
                categoryId: request.categoryId
            )
        }

        let requestBody = Components.Schemas.ClothCreateRequests(content: apiRequests)
        let input = Operations.Cloth_createClothes.Input(body: .json(requestBody))
        let response = try await client.Cloth_createClothes(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseClothCreateResponse.self, from: data)

            guard let clothIds = decoded.result?.clothIds else {
                throw ClothAPIError.noClothIdsReturned
            }
            return clothIds

        case .undocumented(statusCode: let code, let payload):
            // 디버그: 에러 응답 출력
            print("❌ [createClothes] 서버 에러 - 상태코드: \(code)")
            if let body = payload.body {
                let errorData = try await Data(collecting: body, upTo: .max)
                if let errorString = String(data: errorData, encoding: .utf8) {
                    print("❌ [createClothes] 에러 응답: \(errorString)")
                }
            }
            throw ClothAPIError.serverError(statusCode: code, message: "옷 생성 실패")
        }
    }
}

// MARK: - Fetch Clothes

extension ClothAPIService {

    func fetchClothes(lastClothId: Int64?, size: Int32, categoryId: Int64?, seasons: [Season]) async throws -> ClothListResult {
        let seasonsParam = seasons.isEmpty ? nil : seasons.map { mapSeasonToQueryParam($0) }

        let input = Operations.Cloth_getClothes.Input(
            query: .init(lastClothId: lastClothId, size: size, direction: .DESC, categoryId: categoryId, seasons: seasonsParam)
        )

        let response = try await client.Cloth_getClothes(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            // 디버그: 원본 JSON 출력
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📩 [ClothAPI] 옷 목록 응답:")
                print(jsonString.prefix(1000))
            }

            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseClothListResponse.self, from: data)

            let clothes: [ClothListItem] = decoded.result?.content?.map { item -> ClothListItem in
                return ClothListItem(clothId: item.clothId ?? 0, imageUrl: item.ImageUrl ?? "", brand: item.brand, name: item.name)
            } ?? []

            return ClothListResult(clothes: clothes, isLast: decoded.result?.isLast ?? true)

        case .undocumented(statusCode: let code, _):
            throw ClothAPIError.serverError(statusCode: code, message: "옷 목록 조회 실패")
        }
    }

    func fetchClothDetails(clothId: Int64) async throws -> ClothDetailResult {
        let input = Operations.Cloth_getClothDetails.Input(path: .init(clothId: clothId))
        let response = try await client.Cloth_getClothDetails(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseClothDetailsResponse.self, from: data)

            guard let result = decoded.result else {
                throw ClothAPIError.serverError(statusCode: 0, message: "result가 nil입니다")
            }

            return ClothDetailResult(
                clothImageUrl: result.clothImageUrl ?? "",
                parentCategory: result.parentCategory,
                category: result.category,
                name: result.name,
                brand: result.brand,
                clothUrl: result.clothUrl
            )

        case .undocumented(statusCode: let code, _):
            throw ClothAPIError.serverError(statusCode: code, message: "옷 상세 조회 실패")
        }
    }
}

// MARK: - Update & Delete

extension ClothAPIService {

    func updateCloth(clothId: Int64, request: ClothUpdateAPIRequest) async throws {
        let requestBody = Components.Schemas.ClothUpdateRequest(
            clothImageUrl: request.clothImageUrl,
            clothUrl: request.clothUrl,
            name: request.name,
            brand: request.brand,
            season: mapSeasonToUpdateAPI(request.season),
            categoryId: request.categoryId
        )

        let input = Operations.Cloth_updateCloth.Input(path: .init(clothId: clothId), body: .json(requestBody))
        let response = try await client.Cloth_updateCloth(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw ClothAPIError.serverError(statusCode: code, message: "옷 수정 실패")
        }
    }

    func deleteCloth(clothId: Int64) async throws {
        let input = Operations.Cloth_deleteCloth.Input(path: .init(clothId: clothId))
        let response = try await client.Cloth_deleteCloth(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw ClothAPIError.serverError(statusCode: code, message: "옷 삭제 실패")
        }
    }
}

// MARK: - Private Helpers

private extension ClothAPIService {

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

    func mapSeasonToCreateAPI(_ season: Season) -> Components.Schemas.ClothCreateRequest.seasonPayload {
        switch season {
        case .spring: return .SPRING
        case .summer: return .SUMMER
        case .fall: return .FALL
        case .winter: return .WINTER
        }
    }

    func mapSeasonToUpdateAPI(_ season: Season) -> Components.Schemas.ClothUpdateRequest.seasonPayload {
        switch season {
        case .spring: return .SPRING
        case .summer: return .SUMMER
        case .fall: return .FALL
        case .winter: return .WINTER
        }
    }

    func mapSeasonToQueryParam(_ season: Season) -> Operations.Cloth_getClothes.Input.Query.seasonsPayloadPayload {
        switch season {
        case .spring: return .SPRING
        case .summer: return .SUMMER
        case .fall: return .FALL
        case .winter: return .WINTER
        }
    }
}

// MARK: - ClothAPIError

enum ClothAPIError: LocalizedError {
    case presignedUrlMismatch
    case invalidUrl
    case invalidResponse
    case s3UploadFailed(statusCode: Int)
    case noClothIdsReturned
    case serverError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .presignedUrlMismatch:
            return "Presigned URL 개수가 요청한 이미지 개수와 일치하지 않습니다."
        case .invalidUrl:
            return "유효하지 않은 URL입니다."
        case .invalidResponse:
            return "서버 응답을 처리할 수 없습니다."
        case .s3UploadFailed(let statusCode):
            return "S3 업로드 실패 (상태 코드: \(statusCode))"
        case .noClothIdsReturned:
            return "서버에서 생성된 옷 ID를 반환하지 않았습니다."
        case .serverError(let statusCode, let message):
            return "서버 오류 (\(statusCode)): \(message)"
        }
    }
}
