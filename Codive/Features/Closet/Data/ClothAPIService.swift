//
//  ClothAPIService.swift
//  Codive
//
//  Created by 황상환 on 1/12/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - ClothAPIService Protocol

protocol ClothAPIServiceProtocol {
    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo]
    func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws
    func createClothes(requests: [ClothCreateAPIRequest]) async throws -> [Int64]
    func fetchClothes(lastClothId: Int64?, size: Int32, categoryId: Int64?, seasons: [Season]) async throws -> ClothListResult
    func searchClothes(keyword: String, size: Int32, categoryId: Int64?, seasons: [Season]) async throws -> ClothListResult
    func fetchClothDetails(clothId: Int64) async throws -> ClothDetailResult
    func updateCloth(clothId: Int64, request: ClothUpdateAPIRequest) async throws
    func deleteCloth(clothId: Int64) async throws
    
    /// 룩북 전체 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO

    /// AI 옷 정보 추출 (누끼/카테고리/계절)
    func extractClothInfo(clothImageUrls: [String]) async throws -> [ClothAIInfo]
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
    let seasons: [Season]
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
    let parentCategory: String?
    let category: String?
}

struct ClothDetailResult {
    let clothImageUrl: String
    let parentCategory: String?
    let category: String?
    let name: String?
    let brand: String?
    let clothUrl: String?
    let seasons: [Season]
}

struct ClothAIInfo {
    let clothImageUrl: String
    let seasons: Set<Season>
    let parentCategoryId: Int?
    let parentCategoryName: String?
    let categoryId: Int?
    let categoryName: String?
}

struct ClothUpdateAPIRequest {
    let clothImageUrl: String?
    let clothUrl: String?
    let name: String?
    let brand: String?
    let seasons: [Season]        // API에서 required
    let categoryId: Int64        // API에서 required
}

// MARK: - ClothAPIService Implementation

final class ClothAPIService: ClothAPIServiceProtocol {

    let client: Client
    let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }
}

// MARK: - Presigned URL & S3 Upload

extension ClothAPIService {

    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo] {
        let payloads = images.map { imageData in
            let md5Hash = S3UploadHelpers.calculateMD5(from: imageData)
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
                PresignedUrlInfo(presignedUrl: url, finalUrl: S3UploadHelpers.extractFinalUrl(from: url), md5Hash: payloadInfo.md5Hash)
            }

        case .undocumented(statusCode: let code, _):
            throw ClothAPIError.serverError(statusCode: code, message: "Presigned URL 발급 실패")
        }
    }

    func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws {
        try await S3UploadHelpers.uploadToS3(presignedUrl: presignedUrl, imageData: imageData, contentMD5: contentMD5)
    }
}

// MARK: - Create Clothes

extension ClothAPIService {

    func createClothes(requests: [ClothCreateAPIRequest]) async throws -> [Int64] {
        let apiRequests = requests.map { request in
            Components.Schemas.ClothCreateRequest(
                clothImageUrl: request.clothImageUrl,
                clothUrl: request.clothUrl,
                name: request.name,
                brand: request.brand,
                seasons: request.seasons.map { mapSeasonToCreatePayload($0) },
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

        case .undocumented(statusCode: let code, _):
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
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseClothListResponse.self, from: data)

            let clothes: [ClothListItem] = decoded.result?.content?.map { item -> ClothListItem in
                return ClothListItem(
                    clothId: item.clothId ?? 0,
                    imageUrl: item.ImageUrl ?? "",
                    brand: item.brand,
                    name: item.name,
                    parentCategory: item.parentCategory,
                    category: item.category
                )
            } ?? []

            return ClothListResult(clothes: clothes, isLast: decoded.result?.isLast ?? true)

        case .undocumented(statusCode: let code, _):
            throw ClothAPIError.serverError(statusCode: code, message: "옷 목록 조회 실패")
        }
    }

    func searchClothes(keyword: String, size: Int32, categoryId: Int64?, seasons: [Season]) async throws -> ClothListResult {
        let seasonsParam = seasons.isEmpty ? nil : seasons.map { mapSeasonToSearchQueryParam($0) }

        let input = Operations.Search_searchClothes.Input(
            query: .init(keyword: keyword, size: size, direction: .DESC, categoryId: categoryId, seasons: seasonsParam)
        )

        let response = try await client.Search_searchClothes(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseClothListResponse.self, from: data)

            let clothes: [ClothListItem] = decoded.result?.content?.map { item -> ClothListItem in
                return ClothListItem(
                    clothId: item.clothId ?? 0,
                    imageUrl: item.ImageUrl ?? "",
                    brand: item.brand,
                    name: item.name,
                    parentCategory: item.parentCategory,
                    category: item.category
                )
            } ?? []

            return ClothListResult(clothes: clothes, isLast: decoded.result?.isLast ?? true)

        case .undocumented(statusCode: let code, _):
            throw ClothAPIError.serverError(statusCode: code, message: "옷 검색 실패")
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

            let seasons = result.seasons?.compactMap { seasonString -> Season? in
                Season(rawValue: seasonString.rawValue)
            } ?? []

            return ClothDetailResult(
                clothImageUrl: result.clothImageUrl ?? "",
                parentCategory: result.parentCategory,
                category: result.category,
                name: result.name,
                brand: result.brand,
                clothUrl: result.clothUrl,
                seasons: seasons
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
            seasons: request.seasons.map { mapSeasonToUpdatePayload($0) },
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

extension ClothAPIService {
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
            
            let content: [LookBookListResponseItem] = decoded.result?.content?.compactMap { item -> LookBookListResponseItem? in
                guard let lookBookId = item.lookBookId else { return nil }
                return LookBookListResponseItem(lookBookId: lookBookId, lookBookName: item.lookBookName ?? "", imageUrl: item.imageUrl ?? "", count: item.count ?? 0)
            } ?? []
            
            return LookBookListResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "룩북 목록 조회 실패")
        }
    }
}

// MARK: - AI Cloth Detection & Extraction

extension ClothAPIService {

    func extractClothInfo(clothImageUrls: [String]) async throws -> [ClothAIInfo] {
        let requestBody = Components.Schemas.ClothInfoExtractRequest(clothImageUrls: clothImageUrls)
        let input = Operations.ClothAi_extractClothInfo.Input(body: .json(requestBody))

        let response = try await client.ClothAi_extractClothInfo(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(
                Components.Schemas.BaseResponseClothInfoExtractResponse.self,
                from: data
            )

            let results: [ClothAIInfo] = decoded.result?.payloads?.map { payload -> ClothAIInfo in
                let seasons: Set<Season> = Set(
                    payload.seasons?.compactMap { Season(rawValue: $0.rawValue) } ?? []
                )
                return ClothAIInfo(
                    clothImageUrl: payload.clothImageUrl ?? "",
                    seasons: seasons,
                    parentCategoryId: payload.parentCategoryId.map { Int($0) },
                    parentCategoryName: payload.parentCategoryName,
                    categoryId: payload.categoryId.map { Int($0) },
                    categoryName: payload.categoryName
                )
            } ?? []

            return results

        case .undocumented(statusCode: let code, _):
            throw ClothAPIError.serverError(statusCode: code, message: "AI 옷 정보 추출 실패")
        }
    }
}
