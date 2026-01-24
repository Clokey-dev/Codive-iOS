//
//  HomeAPIService.swift
//  Codive
//
//  Created by 한금준 on 1/21/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

// MARK: - HomeCategoryAPIService Protocol

protocol HomeAPIServiceProtocol {
    func fetchRecommendCategoryCloth(lastClothId: Int64?, size: Int32, categoryId: Int64, season: [Season]) async throws -> HomeCategoryResponseDTO
    
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws
    
    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO
}

final class HomeAPIService: HomeAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }
}

extension HomeAPIService {
    
    func fetchRecommendCategoryCloth(lastClothId: Int64?, size: Int32, categoryId: Int64, season: [Season]) async throws -> HomeCategoryResponseDTO {
        guard let firstSeason = season.first else {
                throw HomeAPIError.invalidResponse
            }
        let seasonPayload = mapSeasonToQueryParam(firstSeason)
        
        let input = Operations.Cloth_recommendCategoryClothes.Input(
            query: .init(lastClothId: lastClothId, size: size, categoryId: categoryId, season: seasonPayload)
        )
        
        let response = try await client.Cloth_recommendCategoryClothes(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseClothRecommendListResponse.self, from: data)
            
            let content: [HomeCategoryResponseItem] = decoded.result?.content?.map { item -> HomeCategoryResponseItem in
                return HomeCategoryResponseItem(clothId: item.clothId ?? 0, ImageUrl: item.ImageUrl ?? "")
            } ?? []
            
            return HomeCategoryResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw HomeAPIError.serverError(statusCode: code, message: "옷 목록 조회 실패")
        }
    }
}

extension HomeAPIService {
    
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws {
        let requestBody = Components.Schemas.TemperatureNotificationRequest(
            temperature: request.temperature
        )

        let input = Operations.sendTemperatureNotification.Input(body: .json(requestBody))
        let response = try await client.sendTemperatureNotification(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw HomeAPIError.serverError(statusCode: code, message: "오늘의 기온 알림 보내기 실패")
        }
    }
    
    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO {
        
        let input = Operations.Notification_existsUnreadNotification.Input()
        
        let response = try await client.Notification_existsUnreadNotification(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseUnreadNotificationResponse.self, from: data)
            
            guard let exists = decoded.result?.existsUnreadNotification else {
                throw HomeAPIError.invalidResponse
            }
            
            return NotificationExistAPIResponseDTO(
                existsUnreadNotification: exists
            )
            
        case .undocumented(statusCode: let code, _):
            throw HomeAPIError.serverError(statusCode: code, message: "안읽은 알림 존재 유무 확인 실패")
        }
    }
}

private extension HomeAPIService {

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

    func mapSeasonToQueryParam(
        _ season: Season
    ) -> Operations.Cloth_recommendCategoryClothes.Input.Query.seasonPayload {
        switch season {
        case .spring: return .SPRING
        case .summer: return .SUMMER
        case .fall:   return .FALL
        case .winter: return .WINTER
        }
    }
}

// MARK: - ClothAPIError

enum HomeAPIError: LocalizedError {
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
