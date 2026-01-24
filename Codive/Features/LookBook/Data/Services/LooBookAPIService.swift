//
//  LooBookAPIService.swift
//  Codive
//
//  Created by 한금준 on 1/22/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

// MARK: - HomeCategoryAPIService Protocol

protocol LooBookAPIServiceProtocol {
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO
    
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload
    ) async throws -> LookBookCoordinateResponseDTO
    
    func createLookBook(request: CreateLookBookAPIRequestDTO) async throws -> CreateLookBookResponseDTO
    
    func deleteLookBook(lookBookId: Int64) async throws
    
    func updateLookBook(lookBookId: Int64, request: UpdateLookBookAPIRequestDTO) async throws
}

final class LooBookAPIService: LooBookAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }
}

extension LooBookAPIService {
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
                return LookBookListResponseItem(lookBookId: item.lookBookId ?? 0, lookBookName: item.lookBookName ?? "", imageUrl: item.imageUrl ?? ""/*, count: item.count ?? 0*/)
            } ?? []
            
            return LookBookListResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw LooBookAPIError.serverError(statusCode: code, message: "룩북 목록 조회 실패")
        }
    }
    
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload = .DESC
    ) async throws -> LookBookCoordinateResponseDTO {
        
        let input = Operations.LookBook_getCoordinates.Input(
            path: .init(lookBookId: lookBookId),
            query: .init(
                lastCoordinateId: lastLookBookId,
                size: size,
                direction: direction
            )
        )
        
        let response = try await client.LookBook_getCoordinates(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseCoordinateListResponse.self, from: data)
            
            let content: [LookBookCoordinateListResponseItem] = decoded.result?.content?.map { item -> LookBookCoordinateListResponseItem in
                return LookBookCoordinateListResponseItem(coordinateId: item.coordinateId ?? 0, coordinateName: item.coordinateName ?? "",coordinateLiked: item.coordinateLiked ?? false, imageUrl: item.imageUrl ?? "")
            } ?? []
            
            return LookBookCoordinateResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw LooBookAPIError.serverError(statusCode: code, message: "개별 룩북 코디 목록 조회 실패")
        }
    }
}

extension LooBookAPIService {
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
                throw LooBookAPIError.noClothIdsReturned
            }
            return CreateLookBookResponseDTO(lookBookId: lookBookId)

        case .undocumented(statusCode: let code, _):
            throw LooBookAPIError.serverError(statusCode: code, message: "룩북 생성 실패")
        }
    }
}

extension LooBookAPIService {
    func deleteLookBook(lookBookId: Int64) async throws {
        let input = Operations.LookBook_deleteLookBook.Input(path: .init(lookBookId: lookBookId))
        let response = try await client.LookBook_deleteLookBook(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw LooBookAPIError.serverError(statusCode: code, message: "룩북 삭제 실패")
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
            throw LooBookAPIError.serverError(statusCode: code, message: "룩북 수정 실패")
        }
    }
}

// MARK: - ClothAPIError

enum LooBookAPIError: LocalizedError {
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
