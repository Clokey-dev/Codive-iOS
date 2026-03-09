//
//  ProfileAPIService+Extensions.swift
//  Codive
//
//  Created by 황상환 on 1/25/26.
//

import Foundation
import CodiveAPI

// MARK: - Coordinate Operations

extension ProfileAPIService {
    func fetchMyFavoriteCoordinate() async throws -> [MyFavoriteLookBookResponseDTO] {
        let input = Operations.Coordinate_getFavoriteCoordinates.Input()
        let response = try await client.Coordinate_getFavoriteCoordinates(input)

        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json

            let items = decoded.result ?? []

            return items.map { item in
                MyFavoriteLookBookResponseDTO(
                    coordinateId: item.coordinateId ?? 0,
                    imageUrl: item.imageUrl ?? "",
                    coordinateName: item.coordinateName ?? ""
                )
            }
        case .undocumented(statusCode: let code, _):
            throw ProfileAPIError.serverError(statusCode: code, message: "최애 코디 조회 실패 (상태코드: \(code))")
        }
    }

    func fetchFavoriteCoordinate(memberId: Int) async throws -> [MyFavoriteLookBookResponseDTO] {
        let input = Operations.Coordinate_getFavoriteCoordinates.Input(
            query: .init(memberId: String(memberId))
        )
        let response = try await client.Coordinate_getFavoriteCoordinates(input)

        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json

            let items = decoded.result ?? []

            return items.map { item in
                MyFavoriteLookBookResponseDTO(
                    coordinateId: item.coordinateId ?? 0,
                    imageUrl: item.imageUrl ?? "",
                    coordinateName: item.coordinateName ?? ""
                )
            }
        case .undocumented(statusCode: let code, _):
            throw ProfileAPIError.serverError(statusCode: code, message: "최애 코디 조회 실패 (상태코드: \(code))")
        }
    }

    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewResponseDTO {
        let input = Operations.Coordinate_getCoordinatePreview.Input(
            path: .init(coordinateId: coordinateId)
        )

        let response = try await client.Coordinate_getCoordinatePreview(input)

        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json

            guard let item = decoded.result else {
                throw ProfileAPIError.invalidResponse
            }

            return CoordinatePreviewResponseDTO(
                coordinateId: item.coordinateId ?? 0,
                imageUrl: item.imageUrl ?? "",
                coordinateName: item.coordinateName ?? "",
                coordinateMemo: item.coordinateMemo ?? ""
            )

        case .undocumented(statusCode: let code, _):
            throw ProfileAPIError.serverError(statusCode: code, message: "코디 preview 조회 실패")
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
            let decoded = try okResponse.body.json

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
            throw ProfileAPIError.serverError(statusCode: code, message: "코디 detail 조회 실패")
        }
    }
}

// MARK: - Profile API Error

enum ProfileAPIError: LocalizedError {
    case serverError(statusCode: Int, message: String)
    case invalidResponse
    case invalidUrl
    case s3UploadFailed(statusCode: Int)
    case noData

    var errorDescription: String? {
        switch self {
        case .serverError(let statusCode, let message):
            return "서버 오류 (\(statusCode)): \(message)"
        case .invalidResponse:
            return "올바르지 않은 응답 형식입니다"
        case .invalidUrl:
            return "유효하지 않은 URL입니다"
        case .s3UploadFailed(let statusCode):
            return "S3 업로드 실패 (상태 코드: \(statusCode))"
        case .noData:
            return "응답 데이터가 없습니다"
        }
    }
}
