//
//  LookBookAPIService.swift
//  Codive
//
//  Created by 한금준 on 1/22/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

// MARK: - HomeCategoryAPIService Protocol

protocol LookBookAPIServiceProtocol {
    /// 룩북 전체 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO
    
    /// 개별 룩북 내 코디 조회
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload
    ) async throws -> LookBookCoordinateResponseDTO
    
    /// 과거 일일 코디 조회
    func fetchPastCoordinates(
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.Coordinate_getDailyCoordinates.Input.Query.directionPayload
    ) async throws -> PastDailyCoordinateResponseDTO
    
    /// 코디 preview 조회
    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewResponseDTO
    
    /// 코디 detail 조회
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailResponseDTO]
    
    /// 룩북 생성
    func createLookBook(request: CreateLookBookAPIRequestDTO) async throws -> CreateLookBookResponseDTO
    
    /// 코디 수동 생성
    func createManualCoordinate(request: CreateManualCoordinateAPIRequestDTO) async throws -> CreateManualCoordinateAPIResponseDTO
    
    /// 룩북 삭제
    func deleteLookBook(lookBookId: Int64) async throws
    
    /// 룩북 수정
    func updateLookBook(lookBookId: Int64, request: UpdateLookBookAPIRequestDTO) async throws
    
    /// 코디 삭제
    func deleteCoordinate(coordinateId: Int64) async throws
    
    /// 코디 좋아요 토글
    func patchCoordinateLike(coordinateId: Int64) async throws
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws
    
    /// 이전 일일 코디로 자동 생성
    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> CreateAutoDailyCoordinateAPIResponseDTO
}

final class LookBookAPIService: LookBookAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }
}

extension LookBookAPIService {
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload = .DESC
    ) async throws -> LookBookListResponseDTO {
        
        let input = Operations.LookBook_getLookBooks.Input(
            query: .init(lastLookBookId: lastLookBookId, size: size, direction: direction)
        )
        
        let response = try await client.LookBook_getLookBooks(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseLookBookListResponse.self, from: data)
            
            let content: [LookBookListResponseItem] = decoded.result?.content?.map { item -> LookBookListResponseItem in
                return LookBookListResponseItem(lookBookId: item.lookBookId ?? 0, lookBookName: item.lookBookName ?? "", imageUrl: item.imageUrl ?? "", count: item.count ?? 0)
            } ?? []
            
            return LookBookListResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "룩북 목록 조회 실패")
        }
    }
    
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload = .DESC
    ) async throws -> LookBookCoordinateResponseDTO {
        
        let input = Operations.LookBook_getCoordinates.Input(
            path: .init(lookBookId: lookBookId),
            query: .init(
                lastCoordinateId: lastCoordinateId,
                size: size,
                direction: direction
            )
        )
        
        let response = try await client.LookBook_getCoordinates(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseCoordinateListResponse.self, from: data)
            
            let content: [LookBookCoordinateListResponseItem] =
                decoded.result?.content?.map { item -> LookBookCoordinateListResponseItem in
                    return LookBookCoordinateListResponseItem(
                        coordinateId: item.coordinateId ?? 0,
                        coordinateName: item.coordinateName ?? "",
                        coordinateLiked: item.coordinateLiked ?? false,
                        imageUrl: item.imageUrl ?? ""
                    )
                } ?? []
            
            return LookBookCoordinateResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "개별 룩북 코디 목록 조회 실패")
        }
    }
    
    func fetchPastCoordinates(
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.Coordinate_getDailyCoordinates.Input.Query.directionPayload
    ) async throws -> PastDailyCoordinateResponseDTO {
        let input = Operations.Coordinate_getDailyCoordinates.Input(
            query: .init(
                lastCoordinateId: lastCoordinateId,
                size: size,
                direction: direction
            )
        )
        
        let response = try await client.Coordinate_getDailyCoordinates(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseDailyCoordinateListResponse.self, from: data)
            
            let content: [PastDailyCoordinateListResponseItem] =
                decoded.result?.content?.map { item -> PastDailyCoordinateListResponseItem in
                    return PastDailyCoordinateListResponseItem(
                        coordinateId: item.coordinateId ?? 0,
                        imageUrl: item.imageUrl ?? "",
                        date: formatDate(item.date)
                    )
                } ?? []
            
            return PastDailyCoordinateResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "과거 일일 코디 조회 실패")
        }
    }
    
    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewResponseDTO {
        let input = Operations.Coordinate_getCoordinatePreview.Input(
            path: .init(
                coordinateId: coordinateId
            )
        )
        
        let response = try await client.Coordinate_getCoordinatePreview(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseCoordinatePreviewResponse.self, from: data)
            
            guard let item = decoded.result else {
                throw LookBookAPIError.invalidResponse
            }

            return CoordinatePreviewResponseDTO(
                coordinateId: item.coordinateId ?? 0,
                imageUrl: item.imageUrl ?? "",
                coordinateName: item.coordinateName ?? "",
                coordinateMemo: item.coordinateMemo ?? ""
            )
            
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "코디 preview 조회 실패")
        }
    }
    
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailResponseDTO] {
        let input = Operations.Coordinate_getCoordinateDetails.Input(
            path: .init(
                coordinateId: coordinateId
            )
        )
        
        let response = try await client.Coordinate_getCoordinateDetails(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseListCoordinateDetailsListResponse.self, from: data)
            
            let items = decoded.result ?? []

            return items.map { item in
                CoordinateDetailResponseDTO(
                    coordinateClothId: item.coordinateClothId ?? 0,
                    locationX: item.locationX ?? 0,
                    locationY: item.locationY ?? 0,
                    ratio: item.ratio ?? 1.0,
                    degree: item.degree ?? 0,
                    order: item.order ?? 0,
                    imageUrl: item.imageUrl ?? "",
                    brand: item.brand ?? "",
                    name: item.name ?? "",
                    category: item.category ?? "",
                    parentCategory: item.parentCategory ?? ""
                )
            }
            
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "코디 detail 조회 실패")
        }
    }
}

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

extension LookBookAPIService {
    func patchCoordinateLike(coordinateId: Int64) async throws{
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

extension LookBookAPIService {
    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter.string(from: date)
    }
}

// MARK: - ClothAPIError

enum LookBookAPIError: LocalizedError {
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
