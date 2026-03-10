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
    /// 계절에 따른 카테고리별 옷 리스트
    func fetchRecommendCategoryCloth(lastClothId: Int64?, size: Int32, categoryId: Int64, season: [Season]) async throws -> HomeCategoryResponseDTO
    
    /// 오늘의 온도 알림
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws
    
    /// 오늘의 코디 생성
    func createTodayCoordinate(request: CreateTodayCoordinateRequestDTO) async throws -> CreateTodayCoordinateResponseDTO
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinatePreview() async throws -> FetchTodayCoordinatePreviewResponseDTO
    
    func fetchTodayCoordinateDetails() async throws -> [FetchTodayCoordinateDetailsResponseDTO]
    
    /// 룩북 전체 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws
    
    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> CreateAutoDailyCoordinateAPIResponseDTO
    
    /// 이미지 url 생성
    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo]
}

final class HomeAPIService: HomeAPIServiceProtocol {
    
    private let client: Client
    private let jsonDecoder: JSONDecoder
    
    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createConfiguredClient(
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

        #if DEBUG
        print("[HomeAPI] 카테고리 옷 추천 요청 - categoryId: \(categoryId), season: \(firstSeason.rawValue), size: \(size), lastClothId: \(String(describing: lastClothId))")
        #endif

        let input = Operations.Cloth_recommendCategoryClothes.Input(
            query: .init(lastClothId: lastClothId, size: size, categoryId: categoryId, season: seasonPayload)
        )

        let response = try await client.Cloth_recommendCategoryClothes(input)

        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json

            let content: [HomeCategoryResponseItem] = decoded.result?.content?.map { item -> HomeCategoryResponseItem in
                #if DEBUG
                print("[HomeAPI] 카테고리 옷 아이템 - clothId: \(item.clothId ?? 0), imageUrl: \(item.ImageUrl ?? "nil")")
                #endif
                return HomeCategoryResponseItem(clothId: item.clothId ?? 0, ImageUrl: item.ImageUrl ?? "")
            } ?? []

            #if DEBUG
            print("[HomeAPI] 카테고리 옷 추천 결과 (categoryId: \(categoryId)) - 총 \(content.count)개, isLast: \(decoded.result?.isLast ?? true)")
            #endif

            return HomeCategoryResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)

        case .undocumented(statusCode: let code, _):
            #if DEBUG
            print("[HomeAPI] 카테고리 옷 추천 실패 (categoryId: \(categoryId)) - statusCode: \(code)")
            #endif
            throw HomeAPIError.serverError(statusCode: code, message: "옷 목록 조회 실패")
        }
    }
    
    func fetchTodayCoordinatePreview() async throws -> FetchTodayCoordinatePreviewResponseDTO {
        let input = Operations.Coordinate_getTodayCoordinatePreview.Input()
        
        let response = try await client.Coordinate_getTodayCoordinatePreview(input)
        
        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json
            
            guard let item = decoded.result else {
                throw LookBookAPIError.invalidResponse
            }
            
            return FetchTodayCoordinatePreviewResponseDTO(
                coordinateId: item.coordinateId ?? 0,
                imageUrl: item.imageUrl ?? "",
                date: item.date ?? ""
            )
            
        case .undocumented(statusCode: let code, _):
            throw HomeAPIError.serverError(statusCode: code, message: "오늘의 코디 preview 조회 실패")
        }
    }
    
    func fetchTodayCoordinateDetails() async throws -> [FetchTodayCoordinateDetailsResponseDTO] {
        let input = Operations.Coordinate_getTodayCoordinateDetails.Input()
        
        let response = try await client.Coordinate_getTodayCoordinateDetails(input)
        
        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json
            
            let items = decoded.result ?? []
            
            return items.map { item in
                FetchTodayCoordinateDetailsResponseDTO(
                    coordinateClothId: item.coordinateClothId ?? 0,
                    locationX: item.locationX ?? 0,
                    locationY: item.locationY ?? 0,
                    ratio: item.ratio ?? 0,
                    degree: item.degree ?? 0,
                    order: item.order ?? 0,
                    clothId: item.clothId ?? 0,
                    imageUrl: item.imageUrl ?? "",
                    brand: item.brand ?? "",
                    name: item.name ?? "",
                    category: item.category ?? "",
                    parentCategory: item.parentCategory ?? "",
                )
            }
            
        case .undocumented(statusCode: let code, _):
            throw HomeAPIError.serverError(statusCode: code, message: "오늘의 코디 옷 정보 조회 실패")
        }
    }
    
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
            let decoded = try okResponse.body.json
            
            let content: [LookBookListResponseItem] = decoded.result?.content?.map { item -> LookBookListResponseItem in
                return LookBookListResponseItem(lookBookId: item.lookBookId ?? 0, lookBookName: item.lookBookName ?? "", imageUrl: item.imageUrl ?? "", count: item.count ?? 0)
            } ?? []
            
            return LookBookListResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "룩북 목록 조회 실패")
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
}

extension HomeAPIService {
    func createTodayCoordinate(request: CreateTodayCoordinateRequestDTO) async throws -> CreateTodayCoordinateResponseDTO {
        let requestBody = Components.Schemas.DailyCoordinateCreateRequest(
            coordinateImageUrl: request.coordinateImageUrl,
            payloads: request.payloads.map {
                Components.Schemas.DailyCoordinateCreateRequestPayload(
                    clothId: $0.clothId,
                    locationX: $0.locationX,
                    locationY: $0.locationY,
                    ratio: $0.ratio,
                    degree: $0.degree,
                    order: $0.order
                )
            }
        )
        let input = Operations.Coordinate_createDailyCoordinate.Input(body: .json(requestBody))
        let response = try await client.Coordinate_createDailyCoordinate(input)
        
        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json

            guard let coordinateId = decoded.result?.coordinateId else {
                throw HomeAPIError.invalidResponse
            }
            return CreateTodayCoordinateResponseDTO(coordinateId: coordinateId)
            
        case .undocumented(statusCode: let code, _):
            throw HomeAPIError.serverError(statusCode: code, message: "오늘의 코디 생성 실패")
        }
    }
    
    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo] {
        let payloads = images.map { imageData in
            let md5Hash = calculateMD5(from: imageData)
            let format = S3UploadHelpers.detectFormat(from: imageData)
            return (
                payload: Components.Schemas.ClothImagesUploadRequestPayload(fileExtension: format.clothFileExtension, md5Hashes: md5Hash),
                md5Hash: md5Hash
            )
        }
        
        let requestBody = Components.Schemas.ClothImagesUploadRequest(payloads: payloads.map { $0.payload })
        let input = Operations.ClothAi_getClothUploadPresignedUrl.Input(body: .json(requestBody))
        let response = try await client.ClothAi_getClothUploadPresignedUrl(input)
        
        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json
            
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
            let decoded = try okResponse.body.json

            guard let coordinateId = decoded.result?.coordinateId else {
                throw LookBookAPIError.invalidResponse
            }
            return CreateAutoDailyCoordinateAPIResponseDTO(coordinateId: coordinateId)
            
        case .undocumented(statusCode: let code, _):
            throw LookBookAPIError.serverError(statusCode: code, message: "이전 일일 코디 자동 생성 실패")
        }
    }
}

private extension HomeAPIService {
    
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
