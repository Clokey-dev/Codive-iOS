//
//  TermsAPIService.swift
//  Codive
//
//  Created by Assistant on 1/13/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime

// MARK: - Terms API Service Protocol

protocol TermsAPIServiceProtocol {
    func fetchTerms() async throws -> [TermItem]
    func agreeTerms(agreements: [TermAgreement]) async throws
}

// MARK: - Supporting Types

struct TermItem {
    let termId: Int64
    let title: String
    let isOptional: Bool
}

struct TermAgreement {
    let termId: Int64
    let agreed: Bool
}

// MARK: - Custom Response Types (서버 응답 디코딩용)

private struct TermsResponse: Decodable {
    let isSuccess: Bool?
    let code: String?
    let message: String?
    let result: TermsResult?
}

private struct TermsResult: Decodable {
    let payloads: [TermPayload]?
}

private struct TermPayload: Decodable {
    let termId: Int64?
    let title: String?
    let body: String?
    let optional: Bool?
}

// MARK: - Terms API Service Implementation

final class TermsAPIService: TermsAPIServiceProtocol {

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

            let formatter1 = ISO8601DateFormatter()
            formatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter1.date(from: dateString) { return date }

            let formatter2 = ISO8601DateFormatter()
            formatter2.formatOptions = [.withInternetDateTime]
            if let date = formatter2.date(from: dateString) { return date }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "날짜 파싱 실패")
        }
        return decoder
    }

    // MARK: - GET /terms

    func fetchTerms() async throws -> [TermItem] {
        let input = Operations.Term_getTerms.Input()
        let response = try await client.Term_getTerms(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            // 커스텀 타입으로 디코딩 (서버 응답에 title, optional 필드 있음)
            let decoded = try jsonDecoder.decode(TermsResponse.self, from: data)

            guard let payloads = decoded.result?.payloads else {
                throw TermsAPIError.noData
            }

            return payloads.compactMap { payload in
                guard let termId = payload.termId else { return nil }
                return TermItem(
                    termId: termId,
                    title: payload.title ?? "",
                    isOptional: payload.optional ?? false
                )
            }

        case .undocumented(statusCode: let code, _):
            throw TermsAPIError.serverError(statusCode: code)
        }
    }

    // MARK: - POST /terms

    func agreeTerms(agreements: [TermAgreement]) async throws {
        let payloads = agreements.map { agreement in
            Components.Schemas.Payload(
                termId: agreement.termId,
                agreed: agreement.agreed
            )
        }

        let requestBody = Components.Schemas.TermAgreeRequest(payloads: payloads)
        let input = Operations.Term_agreeTerm.Input(body: .json(requestBody))
        let response = try await client.Term_agreeTerm(input)

        switch response {
        case .ok:
            print("✅ 약관 동의 완료")
            return
        case .undocumented(statusCode: let code, _):
            throw TermsAPIError.serverError(statusCode: code)
        }
    }
}

// MARK: - TermsAPIError

enum TermsAPIError: LocalizedError {
    case noData
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .noData:
            return "약관 데이터가 없습니다."
        case .serverError(let code):
            return "서버 오류 (\(code))"
        }
    }
}
