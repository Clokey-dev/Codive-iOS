//
//  HistoryAPIService.swift
//  Codive
//
//  Created by 황상환 on 1/13/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - History API Service Protocol

protocol HistoryAPIServiceProtocol {
    func createHistory(request: HistoryCreateAPIRequest) async throws -> Int64
}

// MARK: - Request Types

struct HistoryCreateAPIRequest {
    let content: String?
    let situationId: Int64
    let styleIds: [Int64]
    let hashtags: [String]
    let payloads: [HistoryImagePayload]
}

struct HistoryImagePayload {
    let imageUrl: String
    let clothTags: [HistoryClothTag]
}

struct HistoryClothTag {
    let clothId: Int64
    let locationX: Double
    let locationY: Double
}

// MARK: - History API Service Implementation

final class HistoryAPIService: HistoryAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = Self.createJSONDecoder()
    }

    private static func createJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss"
            ]

            for format in formats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: dateString) { return date }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "날짜 파싱 실패: \(dateString)"
            )
        }
        return decoder
    }

    // MARK: - Create History

    func createHistory(request: HistoryCreateAPIRequest) async throws -> Int64 {
        print("📝 [HistoryAPI] 기록 생성 요청")

        // API 요청 바디 생성
        let payloads = request.payloads.map { payload in
            Components.Schemas.HistoryCreatePayload(
                imageUrl: payload.imageUrl,
                clothTags: payload.clothTags.map { tag in
                    Components.Schemas.ClothTag(
                        clothId: tag.clothId,
                        locationX: tag.locationX,
                        locationY: tag.locationY
                    )
                }
            )
        }

        // hashtags를 OpenAPIValueContainer로 변환
        let hashtagContainers: [OpenAPIRuntime.OpenAPIValueContainer]? = request.hashtags.isEmpty
            ? nil
            : request.hashtags.compactMap { try? OpenAPIRuntime.OpenAPIValueContainer(unvalidatedValue: $0) }

        let requestBody = Components.Schemas.HistoryCreateRequest(
            content: request.content,
            situationId: request.situationId,
            styleIds: request.styleIds,
            hashtags: hashtagContainers,
            payloads: payloads
        )

        // 디버그: 요청 바디 출력
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [HistoryAPI] 요청 바디:")
        print("   - content: \(request.content ?? "nil")")
        print("   - situationId: \(request.situationId)")
        print("   - styleIds: \(request.styleIds)")
        print("   - hashtags: \(request.hashtags)")
        print("   - payloads 수: \(payloads.count)")
        for (index, payload) in payloads.enumerated() {
            print("   - payload[\(index)].imageUrl: \(payload.imageUrl ?? "nil")")
            print("   - payload[\(index)].clothTags 수: \(payload.clothTags?.count ?? 0)")
            if let tags = payload.clothTags {
                for (tagIndex, tag) in tags.enumerated() {
                    print("     - tag[\(tagIndex)]: clothId=\(tag.clothId), x=\(tag.locationX), y=\(tag.locationY)")
                }
            }
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        // JSON으로 직접 인코딩해서 확인
        if let jsonData = try? JSONEncoder().encode(requestBody),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 [HistoryAPI] 실제 전송 JSON:")
            print(jsonString)
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }

        let input = Operations.History_createHistory.Input(body: .json(requestBody))
        let response = try await client.History_createHistory(input)

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)

            // 디버그 로그
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📩 [HistoryAPI] 응답: \(jsonString)")
            }

            let decoded = try jsonDecoder.decode(HistoryCreateResponse.self, from: data)

            guard let historyId = decoded.result?.historyId else {
                throw HistoryAPIError.noData
            }

            print("✅ [HistoryAPI] 기록 생성 성공 - historyId: \(historyId)")
            return historyId

        case .undocumented(statusCode: let code, let undocPayload):
            print("❌ [HistoryAPI] 기록 생성 실패: \(code)")
            // 에러 응답 바디 출력
            if let body = undocPayload.body {
                let errorData = try? await Data(collecting: body, upTo: .max)
                if let errorData, let errorString = String(data: errorData, encoding: .utf8) {
                    print("❌ [HistoryAPI] 에러 응답: \(errorString)")
                }
            }
            throw HistoryAPIError.serverError(statusCode: code)
        }
    }
}

// MARK: - Response Types

private struct HistoryCreateResponse: Decodable {
    let isSuccess: Bool?
    let code: String?
    let message: String?
    let result: HistoryResult?

    struct HistoryResult: Decodable {
        let historyId: Int64?
    }
}

// MARK: - Error

enum HistoryAPIError: LocalizedError {
    case noData
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .noData:
            return "응답 데이터가 없습니다."
        case .serverError(let code):
            return "서버 오류 (\(code))"
        }
    }
}
