//
//  LookBookAPIService.swift
//  Codive
//
//  Created by 한금준 on 1/22/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - HomeCategoryAPIService Protocol

final class LookBookAPIService: LookBookAPIServiceProtocol {

    let client: Client
    let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }
}

// MARK: - Fetch Operations

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
            query: .init(lastCoordinateId: lastCoordinateId, size: size, direction: direction)
        )

        let response = try await client.Coordinate_getDailyCoordinates(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            do {
                let decoded = try makeCustomDecoder().decode(
                    Components.Schemas.BaseResponseSliceResponseDailyCoordinateListResponse.self,
                    from: data
                )

                let content: [PastDailyCoordinateListResponseItem] = decoded.result?.content?.map { item in
                    return PastDailyCoordinateListResponseItem(
                        coordinateId: item.coordinateId ?? 0,
                        imageUrl: item.imageUrl ?? "",
                        date: dateToSimpleString(item.date)
                    )
                } ?? []

                return PastDailyCoordinateResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            } catch {
                throw LookBookAPIError.invalidResponse
            }

        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "과거 일일 코디 조회 실패")
        }
    }

    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewResponseDTO {
        let input = Operations.Coordinate_getCoordinatePreview.Input(
            path: .init(coordinateId: coordinateId)
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
            path: .init(coordinateId: coordinateId)
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
                    clothId: item.clothId ?? 0,
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
            throw LookBookAPIError.serverError(statusCode: code, message: "옷 목록 조회 실패")
        }
    }
}
