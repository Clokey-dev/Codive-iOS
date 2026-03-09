//
//  CodiveAPIProvider+Configuration.swift
//  Codive
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import OpenAPIURLSession

extension CodiveAPIProvider {

    static let baseURLString: String = {
        Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? "https://prod.clokey.store"
    }()

    /// 커스텀 날짜 파싱이 적용된 클라이언트 생성
    static func createConfiguredClient(middlewares: [ClientMiddleware] = []) -> Client {
        guard let baseURL = URL(string: baseURLString) else {
            fatalError("BASE_URL is invalid. Check Info.plist or fallback URL.")
        }

        return Client(
            serverURL: baseURL,
            configuration: .init(dateTranscoder: CodiveDateTranscoder()),
            transport: URLSessionTransport(),
            middlewares: middlewares
        )
    }
}
