//
//  TermsAPIService.swift
//  Codive
//
//  Created by 황상환 on 1/13/26.
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
        self.client = CodiveAPIProvider.createConfiguredClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }

    // MARK: - GET /terms
    // 서버 응답의 Payload 필드(title, optional)가 생성된 스키마(termId, agreed)와 불일치하여
    // OpenAPI Client 디코딩이 실패하므로, 직접 URLSession + 커스텀 DTO로 디코딩
    func fetchTerms() async throws -> [TermItem] {
        guard let url = URL(string: "https://prod.clokey.store/terms") else {
            throw TermsAPIError.noData
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = await TokenRefreshManager.shared.getValidToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try jsonDecoder.decode(TermsResponse.self, from: data)

        guard let payloads = decoded.result?.payloads else {
            throw TermsAPIError.noData
        }

        return payloads.compactMap { payload -> TermItem? in
            guard let termId = payload.termId else { return nil }
            return TermItem(
                termId: termId,
                title: payload.title ?? "",
                isOptional: payload.optional ?? false
            )
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
