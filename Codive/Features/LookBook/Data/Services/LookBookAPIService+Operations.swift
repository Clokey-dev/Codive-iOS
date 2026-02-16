//
//  LookBookAPIService+Operations.swift
//  Codive
//
//  Created by 한금준 on 1/22/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

// MARK: - Create Operations

extension LookBookAPIService {
    func createLookBook(request: CreateLookBookAPIRequestDTO) async throws -> CreateLookBookResponseDTO {
        let requestBody = Components.Schemas.LookBookCreateRequest(
            name: request.name
        )
        let input = Operations.LookBook_createLookBook.Input(body: .json(requestBody))
        let response = try await client.LookBook_createLookBook(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseLookBookCreateResponse.self,
                from: data
            )

            guard let lookBookId = decoded.result?.lookBookId else {
                throw LookBookAPIError.noClothIdsReturned
            }
            return CreateLookBookResponseDTO(lookBookId: lookBookId)

        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "룩북 생성 실패")
        }
    }

    func createManualCoordinate(request: CreateManualCoordinateAPIRequestDTO) async throws -> CreateManualCoordinateAPIResponseDTO {
        let requestBody = Components.Schemas.CoordinateManualCreateRequest(
            coordinateImageUrl: request.coordinateImageUrl,
            name: request.name,
            memo: request.memo,
            lookBookId: request.lookBookId,
            payloads: request.payloads.map {
                Components.Schemas.CoordinateManualCreateRequestPayLoad(
                    clothId: $0.clothId,
                    locationX: $0.locationX,
                    locationY: $0.locationY,
                    ratio: $0.ratio,
                    degree: $0.degree,
                    order: $0.order
                )
            }
        )

        let input = Operations.Coordinate_createCoordinateManual.Input(
            body: .json(requestBody)
        )
        let response = try await client.Coordinate_createCoordinateManual(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseCoordinateCreateResponse.self,
                from: data
            )

            guard let coordinateId = decoded.result?.coordinateId else {
                throw LookBookAPIError.invalidResponse
            }
            return CreateManualCoordinateAPIResponseDTO(coordinateId: coordinateId)

        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "코디 수동 생성 실패")
        }
    }

    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> CreateAutoDailyCoordinateAPIResponseDTO {
        let requestBody = Components.Schemas.CoordinateAutoCreateRequest(
            name: request.name,
            memo: request.memo,
            dailyCoordinateId: request.dailyCoordinateId,
            lookBookId: request.lookBookId
        )
        let input = Operations.Coordinate_createCoordinateAuto.Input(body: .json(requestBody))
        let response = try await client.Coordinate_createCoordinateAuto(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseCoordinateCreateResponse.self,
                from: data
            )

            guard let coordinateId = decoded.result?.coordinateId else {
                throw LookBookAPIError.invalidResponse
            }
            return CreateAutoDailyCoordinateAPIResponseDTO(coordinateId: coordinateId)

        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "이전 일일 코디 자동 생성 실패")
        }
    }
}

// MARK: - Delete & Update Operations

extension LookBookAPIService {
    func deleteLookBook(lookBookId: Int64) async throws {
        let input = Operations.LookBook_deleteLookBook.Input(path: .init(lookBookId: lookBookId))
        let response = try await client.LookBook_deleteLookBook(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "룩북 삭제 실패")
        }
    }

    func updateLookBook(lookBookId: Int64, request: UpdateLookBookAPIRequestDTO) async throws {
        let requestBody = Components.Schemas.LookBookUpdateRequest(
            name: request.name
        )

        let input = Operations.LookBook_updateLookBook.Input(path: .init(lookBookId: lookBookId), body: .json(requestBody))
        let response = try await client.LookBook_updateLookBook(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "룩북 수정 실패")
        }
    }

    func deleteCoordinate(coordinateId: Int64) async throws {
        let input = Operations.Coordinate_deleteCoordinate.Input(path: .init(coordinateId: coordinateId))
        let response = try await client.Coordinate_deleteCoordinate(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "코디 삭제 실패")
        }
    }
}

// MARK: - Like & Patch Operations

extension LookBookAPIService {
    func patchCoordinateLike(coordinateId: Int64) async throws {
        let input = Operations.Coordinate_toggleCoordinateLike.Input(path: .init(coordinateId: coordinateId))
        let response = try await client.Coordinate_toggleCoordinateLike(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "코디 좋아요 토글 실패")
        }
    }

    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws {
        let requestBody = Components.Schemas.CoordinateUpdateRequest(
            coordinateImageUrl: request.coordinateImageUrl,
            name: request.name,
            memo: request.memo,
            payloads: request.payloads?.map {
                Components.Schemas.CoordinateUpdateRequestPayload(
                    clothId: $0.clothId,
                    locationX: $0.locationX,
                    locationY: $0.locationY,
                    ratio: $0.ratio,
                    degree: $0.degree,
                    order: Int32($0.order)
                )
            }
        )

        let input = Operations.Coordinate_updateCoordinate.Input(
            path: .init(coordinateId: coordinateId),
            body: .json(requestBody)
        )
        let response = try await client.Coordinate_updateCoordinate(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "코디 수정 실패")
        }
    }
}

// MARK: - Presigned URL

extension LookBookAPIService {
    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo] {
        let payloads = images.map { imageData in
            let md5Hash = calculateMD5(from: imageData)
            return (
                payload: Components.Schemas.ClothImagesUploadRequestPayload(fileExtension: .JPEG, md5Hashes: md5Hash),
                md5Hash: md5Hash
            )
        }

        let requestBody = Components.Schemas.ClothImagesUploadRequest(payloads: payloads.map { $0.payload })
        let input = Operations.ClothAi_getClothUploadPresignedUrl.Input(body: .json(requestBody))
        let response = try await client.ClothAi_getClothUploadPresignedUrl(input)

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
            throw LookBookAPIError.serverError(statusCode: code, message: "Presigned URL 발급 실패")
        }
    }
}

// MARK: - Helpers

extension LookBookAPIService {
    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    func mapSeasonToCreatePayload(_ season: Season) -> Components.Schemas.ClothCreateRequest.seasonsPayloadPayload {
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

    func makeCustomDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "yyyy-MM-dd"

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = simpleFormatter.date(from: dateString) { return date }
            if let date = isoFormatter.date(from: dateString) { return date }

            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateString) { return date }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported date format: \(dateString)"
            )
        }
        return decoder
    }

    func dateToSimpleString(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - LookBookAPIError

enum LookBookAPIError: LocalizedError {
    case presignedUrlMismatch
    case invalidUrl
    case invalidResponse
    case invalidImageData
    case uploadFailed(message: String)
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
        case .invalidImageData:
            return "이미지 데이터가 올바르지 않습니다."
        case .uploadFailed(let message):
            return "업로드 실패: \(message)"
        }
    }
}
