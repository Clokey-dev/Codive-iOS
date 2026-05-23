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
    func getFavoriteItems() async throws -> [FavoriteItemPayload]
    func getFavoriteCategoryItems(categoryId: Int64) async throws -> [FavoriteCategoryItemPayload]
    func getClosetUtilization(season: String) async throws -> ClosetUtilizationPayload
}

// MARK: - API Response DTOs

struct FavoriteItemPayload {
    let categoryId: Int64?
    let categoryName: String
    let clothCount: Int
}

struct FavoriteCategoryItemPayload {
    let categoryId: Int64?
    let categoryName: String
    let occupancyRate: Double
    let clothCount: Int
}

struct ClosetUtilizationPayload {
    let utilizedCount: Int
    let unutilizedCount: Int
    let utilizedClothes: [ClosetUtilizationClothPayload]
    let unutilizedClothes: [ClosetUtilizationClothPayload]
}

struct ClosetUtilizationClothPayload {
    let imageUrl: String
    let name: String
    let brand: String
}

// MARK: - StatisticsAPIService Implementation

final class StatisticsAPIService: StatisticsAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createConfiguredClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }

    // MARK: - Check Condition

    func checkStatisticsCondition() async throws -> Bool {
        let input = Operations.Statistics_checkStatisticsCondition.Input()
        #if DEBUG
        print("[StatisticsAPI] 통계 조건 확인 요청 시작")
        #endif
        let response = try await client.Statistics_checkStatisticsCondition(input)

        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json
            #if DEBUG
            print("[StatisticsAPI] 응답 성공 - canAggregate: \(decoded.result?.canAggregate ?? false)")
            #endif
            return decoded.result?.canAggregate ?? false

        case .undocumented(statusCode: let code, _):
            #if DEBUG
            print("[StatisticsAPI] 응답 실패 - statusCode: \(code)")
            #endif
            throw StatisticsAPIError.serverError(statusCode: code, message: "통계 조건 확인 실패")
        }
    }

    // MARK: - Favorite Items (옷장 아이템 통계)

    func getFavoriteItems() async throws -> [FavoriteItemPayload] {
        let input = Operations.Statistics_getFavoriteItems.Input()
        #if DEBUG
        print("[StatisticsAPI] 옷장 아이템 통계 요청 시작")
        #endif
        let response = try await client.Statistics_getFavoriteItems(input)

        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json
            #if DEBUG
            print("[StatisticsAPI] 아이템 통계 응답 성공")
            #endif
            return (decoded.result?.payloads ?? []).map { payload in
                FavoriteItemPayload(
                    categoryId: payload.categoryId,
                    categoryName: payload.categoryName ?? "",
                    clothCount: Int(payload.clothCount ?? 0)
                )
            }

        case .undocumented(statusCode: let code, _):
            throw StatisticsAPIError.serverError(statusCode: code, message: "아이템 통계 조회 실패")
        }
    }

    // MARK: - Favorite Category Items (카테고리별 최애 아이템)

    func getFavoriteCategoryItems(categoryId: Int64) async throws -> [FavoriteCategoryItemPayload] {
        let input = Operations.Statistics_getFavoriteCategoryItems.Input(
            query: .init(categoryId: categoryId)
        )
        #if DEBUG
        print("[StatisticsAPI] 카테고리별 아이템 통계 요청 - categoryId: \(categoryId)")
        #endif
        let response = try await client.Statistics_getFavoriteCategoryItems(input)

        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json
            #if DEBUG
            print("[StatisticsAPI] 카테고리별 아이템 응답 성공")
            #endif
            return (decoded.result?.payloads ?? []).map { payload in
                FavoriteCategoryItemPayload(
                    categoryId: payload.categoryId,
                    categoryName: payload.categoryName ?? "",
                    occupancyRate: payload.occupancyRate ?? 0,
                    clothCount: Int(payload.clothCount ?? 0)
                )
            }

        case .undocumented(statusCode: let code, _):
            throw StatisticsAPIError.serverError(statusCode: code, message: "카테고리별 아이템 조회 실패")
        }
    }

    // MARK: - Closet Utilization (옷장 활용도)

    func getClosetUtilization(season: String) async throws -> ClosetUtilizationPayload {
        let seasonEnum: Operations.Statistics_getClosetUtilization.Input.Query.seasonPayload
        switch season.uppercased() {
        case "SPRING": seasonEnum = .SPRING
        case "SUMMER": seasonEnum = .SUMMER
        case "FALL": seasonEnum = .FALL
        case "WINTER": seasonEnum = .WINTER
        default: seasonEnum = .SPRING
        }

        let input = Operations.Statistics_getClosetUtilization.Input(
            query: .init(season: seasonEnum)
        )
        #if DEBUG
        print("[StatisticsAPI] 옷장 활용도 요청 - season: \(season)")
        #endif
        let response = try await client.Statistics_getClosetUtilization(input)

        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json
            let result = decoded.result
            #if DEBUG
            print("[StatisticsAPI] 활용도 응답 성공 - utilized: \(result?.utilizedCount ?? 0), unutilized: \(result?.unutilizedCount ?? 0)")
            #endif
            return ClosetUtilizationPayload(
                utilizedCount: Int(result?.utilizedCount ?? 0),
                unutilizedCount: Int(result?.unutilizedCount ?? 0),
                utilizedClothes: (result?.utilizedClothes ?? []).map {
                    ClosetUtilizationClothPayload(
                        imageUrl: $0.imageUrl ?? "",
                        name: $0.name ?? "",
                        brand: $0.brand ?? ""
                    )
                },
                unutilizedClothes: (result?.unutilizedClothes ?? []).map {
                    ClosetUtilizationClothPayload(
                        imageUrl: $0.imageUrl ?? "",
                        name: $0.name ?? "",
                        brand: $0.brand ?? ""
                    )
                }
            )

        case .undocumented(statusCode: let code, _):
            throw StatisticsAPIError.serverError(statusCode: code, message: "옷장 활용도 조회 실패")
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
