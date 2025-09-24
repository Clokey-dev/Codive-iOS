//
//  NetworkManager.swift
//  Codive
//
//  Created by 황상환 on 9/21/25.
//

import Foundation
import Moya

// MARK: - 프로토콜 정의

/// Moya의 TargetType을 기반으로 다양한 API 요청을 처리하기 위한 공통 인터페이스.
/// SwiftUI에서도 각 ViewModel이 이 프로토콜을 통해 네트워크 요청을 보냄.
protocol NetworkManager {
    associatedtype Endpoint: TargetType
    var provider: MoyaProvider<Endpoint> { get }

    /// 일반적인 응답이 있는 API 요청
    func request<T: Decodable>(target: Endpoint, decodingType: T.Type) async throws -> T

    /// 응답이 Optional인 경우 (데이터가 없을 수도 있음)
    func requestOptional<T: Decodable>(target: Endpoint, decodingType: T.Type) async throws -> T?

    /// 응답 데이터 없이 상태 코드로만 성공 여부 판단 (204, 200 등)
    func requestStatusCode(target: Endpoint) async throws

    /// 응답 + Cache-Control max-age 정보까지 함께 반환하는 요청
    func requestWithTime<T: Decodable>(target: Endpoint, decodingType: T.Type) async throws -> (T, TimeInterval?)
}

// MARK: - 구현체

/// NetworkManager 프로토콜을 실제로 구현한 기본 네트워크 매니저.
/// ViewModel에서 `DefaultNetworkManager<SomeAPI>()` 형태로 사용.
final class DefaultNetworkManager<API: TargetType>: NetworkManager {
    typealias Endpoint = API
    let provider: MoyaProvider<API>

    /// 테스트(stub) 여부에 따라 실제 네트워크 or 즉시 응답 선택 가능
    init(stub: Bool = false) {
        if stub {
            provider = MoyaProvider<API>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            provider = MoyaProvider<API>()
        }
    }

    // MARK: - 실제 요청 함수 구현

    func request<T: Decodable>(target: Endpoint, decodingType: T.Type) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { [self] result in
                switch result {
                case .success(let response):
                    let decoded = handleResponse(response, decodingType: decodingType)
                    continuation.resume(with: decoded)
                case .failure(let error):
                    continuation.resume(throwing: handleNetworkError(error))
                }
            }
        }
    }

    func requestOptional<T: Decodable>(target: Endpoint, decodingType: T.Type) async throws -> T? {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { [self] result in
                switch result {
                case .success(let response):
                    do {
                        guard (200...299).contains(response.statusCode) else {
                            let error = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                            throw NetworkError.serverError(statusCode: response.statusCode, message: error?.message ?? "서버 오류")
                        }

                        if response.data.isEmpty {
                            continuation.resume(returning: nil)
                            return
                        }

                        let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
                        continuation.resume(returning: apiResponse.result)
                    } catch {
                        if let networkError = error as? NetworkError {
                            continuation.resume(throwing: networkError)
                        } else if let decodingError = error as? DecodingError {
                            continuation.resume(throwing: NetworkError.decodingError(underlyingError: decodingError))
                        } else {
                            continuation.resume(throwing: NetworkError.unknown)
                        }
                    }

                case .failure(let error):
                    continuation.resume(throwing: handleNetworkError(error))
                }
            }
        }
    }

    func requestStatusCode(target: Endpoint) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { [self] result in
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        continuation.resume()
                    } else {
                        let error = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                        continuation.resume(throwing: NetworkError.serverError(statusCode: response.statusCode, message: error?.message ?? "상태 코드 오류"))
                    }
                case .failure(let error):
                    continuation.resume(throwing: handleNetworkError(error))
                }
            }
        }
    }

    func requestWithTime<T: Decodable>(target: Endpoint, decodingType: T.Type) async throws -> (T, TimeInterval?) {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { [self] result in
                switch result {
                case .success(let response):
                    do {
                        guard (200...299).contains(response.statusCode) else {
                            let error = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                            throw NetworkError.serverError(statusCode: response.statusCode, message: error?.message ?? "서버 오류")
                        }

                        let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
                        guard let result = apiResponse.result else {
                            throw NetworkError.serverError(statusCode: response.statusCode, message: "결과 없음")
                        }

                        let cacheTime = extractCacheTimeInterval(from: response)
                        continuation.resume(returning: (result, cacheTime))
                    } catch {
                        if let networkError = error as? NetworkError {
                            continuation.resume(throwing: networkError)
                        } else {
                            if let decodingError = error as? DecodingError {
                                continuation.resume(throwing: NetworkError.decodingError(underlyingError: decodingError))
                            } else {
                                continuation.resume(throwing: NetworkError.unknown)
                            }
                        }
                    }
                case .failure(let error):
                    continuation.resume(throwing: handleNetworkError(error))
                }
            }
        }
    }

    // MARK: - 내부 유틸리티 함수

    /// 공통 응답 처리 로직 (성공/실패/디코딩)
    private func handleResponse<T: Decodable>(_ response: Response, decodingType: T.Type) -> Result<T, NetworkError> {
        do {
            guard (200...299).contains(response.statusCode) else {
                let error = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                return .failure(.serverError(statusCode: response.statusCode, message: error?.message ?? "서버 오류"))
            }
            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
            guard let result = apiResponse.result else {
                return .failure(.serverError(statusCode: response.statusCode, message: "결과 없음"))
            }
            return .success(result)
        } catch {
            return .failure(.decodingError(underlyingError: error as? DecodingError ?? DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown decoding error"))))
        }
    }

    /// Moya에서 받은 네트워크 에러를 우리 서비스용 에러로 변환
    private func handleNetworkError(_ error: Error) -> NetworkError {
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return .networkError(message: "인터넷 연결 없음")
        case NSURLErrorTimedOut:
            return .networkError(message: "요청 시간 초과")
        default:
            return .networkError(message: "알 수 없는 네트워크 오류")
        }
    }

    /// Cache-Control max-age 파싱 함수 (requestWithTime에서 사용)
    private func extractCacheTimeInterval(from: Response) -> TimeInterval? {
        guard let cacheControl = from.response?.allHeaderFields["Cache-Control"] as? String else { return nil }
        let components = cacheControl.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for component in components where component.starts(with: "max-age") {
            if let value = component.split(separator: "=").last, let interval = TimeInterval(value) {
                return interval
            }
        }
        return nil
    }
}
