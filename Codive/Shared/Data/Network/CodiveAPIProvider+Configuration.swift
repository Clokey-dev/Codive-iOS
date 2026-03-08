//
//  CodiveAPIProvider+Configuration.swift
//  Codive
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import OpenAPIURLSession

extension CodiveAPIProvider {

    /// 커스텀 날짜 파싱이 적용된 클라이언트 생성
    static func createConfiguredClient(middlewares: [ClientMiddleware] = []) -> Client {
        guard let baseURL = URL(string: "https://prod.clokey.store") else {
            fatalError("Hardcoded BASE_URL is invalid. Check the URL string.")
        }

        return Client(
            serverURL: baseURL,
            configuration: .init(dateTranscoder: CodiveDateTranscoder()),
            transport: URLSessionTransport(),
            middlewares: middlewares
        )
    }
}
