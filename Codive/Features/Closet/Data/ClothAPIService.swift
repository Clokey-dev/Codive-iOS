//
//  ClothAPIService.swift
//  Codive
//
//  Created by Assistant on 1/12/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

// MARK: - ClothAPIService Protocol

protocol ClothAPIServiceProtocol {
    /// Presigned URL 발급 요청
    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo]
    
    /// S3에 이미지 업로드
    func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws
    
    /// 옷 생성 API 호출
    func createClothes(requests: [ClothCreateAPIRequest]) async throws -> [Int64]
    
    /// 옷 목록 조회
    func fetchClothes(
        lastClothId: Int64?,
        size: Int32,
        categoryId: Int64?,
        seasons: [Season]
    ) async throws -> ClothListResult
    
    /// 옷 상세 조회
    func fetchClothDetails(clothId: Int64) async throws -> ClothDetailResult
}

// MARK: - Supporting Types

/// Presigned URL 정보
struct PresignedUrlInfo {
    let presignedUrl: String      // 전체 presigned URL (업로드용)
    let finalUrl: String          // 최종 S3 URL (쿼리 파라미터 제거됨)
    let md5Hash: String           // MD5 해시 (업로드 시 헤더에 필요)
}

/// 옷 생성 요청 데이터
struct ClothCreateAPIRequest {
    let clothImageUrl: String     // S3에 업로드된 이미지 URL
    let clothUrl: String?         // 구매 링크 (선택)
    let name: String?             // 옷 이름 (선택)
    let brand: String?            // 브랜드 (선택)
    let season: Season            // 계절 (필수)
    let categoryId: Int64         // 카테고리 ID (필수)
}

/// 옷 목록 조회 결과
struct ClothListResult {
    let clothes: [ClothListItem]
    let isLast: Bool
}

/// 옷 목록 아이템 (목록 조회용)
struct ClothListItem {
    let clothId: Int64
    let imageUrl: String
    let brand: String?
    let name: String?
}

/// 옷 상세 조회 결과
struct ClothDetailResult {
    let clothImageUrl: String
    let parentCategory: String?
    let category: String?
    let name: String?
    let brand: String?
    let clothUrl: String?
}

// MARK: - ClothAPIService Implementation

final class ClothAPIService: ClothAPIServiceProtocol {
    
    // MARK: - Properties
    
    private let client: Client
    private let jsonDecoder: JSONDecoder
    
    // MARK: - Initializer
    
    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        
        // 서버의 timeStamp 형식 (나노초 포함) 처리를 위한 커스텀 DateFormatter
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // 여러 ISO8601 형식 시도
            let formatters: [ISO8601DateFormatter] = {
                let formatter1 = ISO8601DateFormatter()
                formatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let formatter2 = ISO8601DateFormatter()
                formatter2.formatOptions = [.withInternetDateTime]
                
                return [formatter1, formatter2]
            }()
            
            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            // ISO8601로 파싱 실패 시 DateFormatter 사용
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "날짜 형식을 파싱할 수 없습니다: \(dateString)"
            )
        }
    }
    
    // MARK: - Public Methods
    
    /// Step 1: Presigned URL 발급 요청
    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo] {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [API] Presigned URL 발급 요청 시작")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        // 각 이미지에 대한 MD5 해시 계산 및 payload 생성
        let payloads = images.enumerated().map { index, imageData in
            let md5Hash = calculateMD5(from: imageData)
            print("   📦 이미지 \(index + 1):")
            print("      - 크기: \(imageData.count) bytes")
            print("      - MD5: \(md5Hash)")
            return (
                payload: Components.Schemas.ClothImagesUploadRequestPayload(
                    fileExtension: .JPEG,
                    md5Hashes: md5Hash
                ),
                md5Hash: md5Hash
            )
        }
        
        // API 요청
        let requestBody = Components.Schemas.ClothImagesUploadRequest(
            payloads: payloads.map { $0.payload }
        )
        
        print("   📨 요청 Body:")
        print("      - payloads 개수: \(payloads.count)")
        for (index, payload) in payloads.enumerated() {
            print("      - [\(index)] fileExtension: JPEG, md5Hashes: \(payload.md5Hash)")
        }
        
        let input = Operations.Cloth_getClothUploadPresignedUrl.Input(
            body: .json(requestBody)
        )
        
        do {
            let response = try await client.Cloth_getClothUploadPresignedUrl(input)
            
            switch response {
            case .ok(let okResponse):
                let httpBody = try okResponse.body.any
                let data = try await Data(collecting: httpBody, upTo: .max)
                
                print("   ✅ 응답 수신 (성공)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("   📩 응답 Body: \(jsonString)")
                }
                
                let decoded = try jsonDecoder.decode(
                    Components.Schemas.BaseResponseClothImagesPresignedUrlResponse.self,
                    from: data
                )
                
                print("   📋 파싱 결과:")
                print("      - isSuccess: \(decoded.isSuccess ?? false)")
                print("      - code: \(decoded.code ?? "nil")")
                print("      - message: \(decoded.message ?? "nil")")
                print("      - urls 개수: \(decoded.result?.urls?.count ?? 0)")
                
                guard let urls = decoded.result?.urls, urls.count == images.count else {
                    print("   ❌ URL 개수 불일치! 요청: \(images.count), 응답: \(decoded.result?.urls?.count ?? 0)")
                    throw ClothAPIError.presignedUrlMismatch
                }
                
                // Presigned URL과 MD5 해시를 함께 반환
                let result = zip(urls, payloads).map { url, payloadInfo in
                    let finalUrl = extractFinalUrl(from: url)
                    print("      - Presigned URL: \(url.prefix(80))...")
                    print("      - Final URL: \(finalUrl)")
                    return PresignedUrlInfo(
                        presignedUrl: url,
                        finalUrl: finalUrl,
                        md5Hash: payloadInfo.md5Hash
                    )
                }
                
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                return result
                
            case .undocumented(statusCode: let code, let payload):
                print("   ❌ 응답 수신 (실패) - 상태코드: \(code)")
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("   📩 에러 응답 Body: \(jsonString)")
                    }
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                throw ClothAPIError.serverError(statusCode: code, message: "Presigned URL 발급 실패")
            }
        } catch {
            print("   ❌ 예외 발생: \(error)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            throw error
        }
    }
    
    /// Step 1.5: S3에 이미지 직접 업로드
    func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [S3] 이미지 업로드 시작")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        guard let url = URL(string: presignedUrl) else {
            print("   ❌ URL 파싱 실패: \(presignedUrl)")
            throw ClothAPIError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue(contentMD5, forHTTPHeaderField: "Content-MD5")
        request.httpBody = imageData
        
        print("   📨 요청 정보:")
        print("      - Method: PUT")
        print("      - URL: \(presignedUrl)")
        print("   📋 요청 헤더:")
        print("      - Content-Type: image/jpeg")
        print("      - Content-MD5: \(contentMD5)")
        print("   📦 요청 Body:")
        print("      - Image Size: \(imageData.count) bytes (\(String(format: "%.2f", Double(imageData.count) / 1024.0)) KB)")
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("   ❌ HTTP 응답 아님")
                throw ClothAPIError.invalidResponse
            }
            
            print("   📩 응답 수신:")
            print("      - 상태코드: \(httpResponse.statusCode)")
            print("   📋 응답 헤더:")
            for (key, value) in httpResponse.allHeaderFields {
                print("      - \(key): \(value)")
            }
            
            if !responseData.isEmpty {
                if let responseString = String(data: responseData, encoding: .utf8) {
                    print("   📩 응답 Body: \(responseString)")
                } else {
                    print("   📩 응답 Body: (바이너리 데이터 \(responseData.count) bytes)")
                }
            } else {
                print("   📩 응답 Body: (비어있음)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("   ❌ S3 업로드 실패!")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                throw ClothAPIError.s3UploadFailed(statusCode: httpResponse.statusCode)
            }
            
            print("   ✅ S3 업로드 성공!")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
        } catch {
            print("   ❌ 예외 발생: \(error)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            throw error
        }
    }
    
    /// Step 2: 옷 생성 API 호출
    func createClothes(requests: [ClothCreateAPIRequest]) async throws -> [Int64] {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [API] 옷 생성 요청 시작")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        // ClothCreateAPIRequest → Components.Schemas.ClothCreateRequest 변환
        let apiRequests = requests.enumerated().map { index, request in
            print("   📦 옷 \(index + 1):")
            print("      - clothImageUrl: \(request.clothImageUrl)")
            print("      - clothUrl: \(request.clothUrl ?? "nil")")
            print("      - name: \(request.name ?? "nil")")
            print("      - brand: \(request.brand ?? "nil")")
            print("      - season: \(request.season.rawValue)")
            print("      - categoryId: \(request.categoryId)")
            
            return Components.Schemas.ClothCreateRequest(
                clothImageUrl: request.clothImageUrl,
                clothUrl: request.clothUrl,
                name: request.name,
                brand: request.brand,
                season: mapSeasonToAPI(request.season),
                categoryId: request.categoryId
            )
        }
        
        let requestBody = Components.Schemas.ClothCreateRequests(content: apiRequests)
        
        // JSON으로 변환해서 출력
        if let jsonData = try? JSONEncoder().encode(requestBody),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("   📨 요청 Body (JSON): \(jsonString)")
        }
        
        let input = Operations.Cloth_createClothes.Input(
            body: .json(requestBody)
        )
        
        do {
            let response = try await client.Cloth_createClothes(input)
            
            switch response {
            case .ok(let okResponse):
                let httpBody = try okResponse.body.any
                let data = try await Data(collecting: httpBody, upTo: .max)
                
                print("   ✅ 응답 수신 (성공)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("   📩 응답 Body: \(jsonString)")
                }
                
                let decoded = try jsonDecoder.decode(
                    Components.Schemas.BaseResponseClothCreateResponse.self,
                    from: data
                )
                
                print("   📋 파싱 결과:")
                print("      - isSuccess: \(decoded.isSuccess ?? false)")
                print("      - code: \(decoded.code ?? "nil")")
                print("      - message: \(decoded.message ?? "nil")")
                print("      - clothIds: \(decoded.result?.clothIds ?? [])")
                
                guard let clothIds = decoded.result?.clothIds else {
                    print("   ❌ clothIds가 nil!")
                    throw ClothAPIError.noClothIdsReturned
                }
                
                print("   ✅ 옷 생성 완료! IDs: \(clothIds)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                return clothIds
                
            case .undocumented(statusCode: let code, let payload):
                print("   ❌ 응답 수신 (실패) - 상태코드: \(code)")
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("   📩 에러 응답 Body: \(jsonString)")
                    }
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                throw ClothAPIError.serverError(statusCode: code, message: "옷 생성 실패")
            }
        } catch {
            print("   ❌ 예외 발생: \(error)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    /// MD5 해시 계산 (Base64 인코딩)
    private func calculateMD5(from data: Data) -> String {
        let digest = Insecure.MD5.hash(data: data)
        return Data(digest).base64EncodedString()
    }
    
    /// Presigned URL에서 최종 S3 URL 추출 (쿼리 파라미터 제거)
    private func extractFinalUrl(from presignedUrl: String) -> String {
        guard let url = URL(string: presignedUrl),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return presignedUrl
        }
        components.query = nil
        return components.string ?? presignedUrl
    }
    
    /// Season enum → API enum 변환
    private func mapSeasonToAPI(_ season: Season) -> Components.Schemas.ClothCreateRequest.seasonPayload {
        switch season {
        case .spring: return .SPRING
        case .summer: return .SUMMER
        case .fall: return .FALL
        case .winter: return .WINTER
        }
    }
    
    /// Season enum → Query param enum 변환
    private func mapSeasonToQueryParam(_ season: Season) -> Operations.Cloth_getClothes.Input.Query.seasonsPayloadPayload {
        switch season {
        case .spring: return .SPRING
        case .summer: return .SUMMER
        case .fall: return .FALL
        case .winter: return .WINTER
        }
    }
    
    // MARK: - 옷 목록 조회
    
    func fetchClothes(
        lastClothId: Int64?,
        size: Int32,
        categoryId: Int64?,
        seasons: [Season]
    ) async throws -> ClothListResult {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [API] 옷 목록 조회 요청")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   📋 요청 파라미터:")
        print("      - lastClothId: \(lastClothId?.description ?? "nil")")
        print("      - size: \(size)")
        print("      - categoryId: \(categoryId?.description ?? "nil")")
        print("      - seasons: \(seasons.map { $0.rawValue })")
        
        let seasonsParam: [Operations.Cloth_getClothes.Input.Query.seasonsPayloadPayload]? = seasons.isEmpty ? nil : seasons.map { mapSeasonToQueryParam($0) }
        
        let input = Operations.Cloth_getClothes.Input(
            query: .init(
                lastClothId: lastClothId,
                size: size,
                direction: .DESC,
                categoryId: categoryId,
                seasons: seasonsParam
            )
        )
        
        do {
            let response = try await client.Cloth_getClothes(input)
            
            switch response {
            case .ok(let okResponse):
                let httpBody = try okResponse.body.any
                let data = try await Data(collecting: httpBody, upTo: .max)
                
                print("   ✅ 응답 수신 (성공)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("   📩 응답 Body: \(jsonString.prefix(500))...")
                }
                
                let decoded = try jsonDecoder.decode(
                    Components.Schemas.BaseResponseSliceResponseClothListResponse.self,
                    from: data
                )
                
                print("   📋 파싱 결과:")
                print("      - isSuccess: \(decoded.isSuccess ?? false)")
                print("      - code: \(decoded.code ?? "nil")")
                print("      - 옷 개수: \(decoded.result?.content?.count ?? 0)")
                print("      - isLast: \(decoded.result?.isLast ?? false)")
                
                let clothes = decoded.result?.content?.map { item in
                    ClothListItem(
                        clothId: item.clothId ?? 0,
                        imageUrl: item.ImageUrl ?? "",  // API 응답의 대문자 I 주의
                        brand: item.brand,
                        name: item.name
                    )
                } ?? []
                
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                return ClothListResult(
                    clothes: clothes,
                    isLast: decoded.result?.isLast ?? true
                )
                
            case .undocumented(statusCode: let code, let payload):
                print("   ❌ 응답 수신 (실패) - 상태코드: \(code)")
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("   📩 에러 응답 Body: \(jsonString)")
                    }
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                throw ClothAPIError.serverError(statusCode: code, message: "옷 목록 조회 실패")
            }
        } catch {
            print("   ❌ 예외 발생: \(error)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            throw error
        }
    }
    
    // MARK: - 옷 상세 조회
    
    func fetchClothDetails(clothId: Int64) async throws -> ClothDetailResult {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [API] 옷 상세 조회 요청")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   📋 요청 파라미터: clothId = \(clothId)")
        
        let input = Operations.Cloth_getClothDetails.Input(
            path: .init(clothId: clothId)
        )
        
        do {
            let response = try await client.Cloth_getClothDetails(input)
            
            switch response {
            case .ok(let okResponse):
                let httpBody = try okResponse.body.any
                let data = try await Data(collecting: httpBody, upTo: .max)
                
                print("   ✅ 응답 수신 (성공)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("   📩 응답 Body: \(jsonString)")
                }
                
                let decoded = try jsonDecoder.decode(
                    Components.Schemas.BaseResponseClothDetailsResponse.self,
                    from: data
                )
                
                print("   📋 파싱 결과:")
                print("      - isSuccess: \(decoded.isSuccess ?? false)")
                print("      - code: \(decoded.code ?? "nil")")
                print("      - name: \(decoded.result?.name ?? "nil")")
                print("      - brand: \(decoded.result?.brand ?? "nil")")
                print("      - category: \(decoded.result?.category ?? "nil")")
                
                guard let result = decoded.result else {
                    throw ClothAPIError.serverError(statusCode: 0, message: "result가 nil입니다")
                }
                
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                return ClothDetailResult(
                    clothImageUrl: result.clothImageUrl ?? "",
                    parentCategory: result.parentCategory,
                    category: result.category,
                    name: result.name,
                    brand: result.brand,
                    clothUrl: result.clothUrl
                )
                
            case .undocumented(statusCode: let code, let payload):
                print("   ❌ 응답 수신 (실패) - 상태코드: \(code)")
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("   📩 에러 응답 Body: \(jsonString)")
                    }
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                throw ClothAPIError.serverError(statusCode: code, message: "옷 상세 조회 실패")
            }
        } catch {
            print("   ❌ 예외 발생: \(error)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            throw error
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
