//
//  TokenService.swift
//  Codive
//
//  Created by 황상환 on 1/13/26.
//

import Foundation

// MARK: - Token Service Protocol

protocol TokenServiceProtocol {
    func isAccessTokenExpired() -> Bool
    func isRefreshTokenExpired() -> Bool
    func hasValidTokens() -> Bool
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
}

// MARK: - Token Service Implementation

final class TokenService: TokenServiceProtocol {

    private let keychainManager: KeychainManager

    // 토큰 만료 여유 시간 (5분 전에 만료로 간주)
    private let expirationBuffer: TimeInterval = 300

    init(keychainManager: KeychainManager = KeychainManager.shared) {
        self.keychainManager = keychainManager
    }

    // MARK: - Public Methods

    /// 키체인에 유효한 토큰이 있는지 확인
    func hasValidTokens() -> Bool {
        guard let _ = getAccessToken(), let _ = getRefreshToken() else {
            return false
        }
        return true
    }

    /// Access Token 만료 여부 확인
    func isAccessTokenExpired() -> Bool {
        guard let token = getAccessToken() else { return true }
        return isTokenExpired(token)
    }

    /// Refresh Token 만료 여부 확인
    func isRefreshTokenExpired() -> Bool {
        guard let token = getRefreshToken() else { return true }
        return isTokenExpired(token)
    }

    /// Access Token 가져오기
    func getAccessToken() -> String? {
        return try? keychainManager.getAccessToken()
    }

    /// Refresh Token 가져오기
    func getRefreshToken() -> String? {
        return try? keychainManager.getRefreshToken()
    }

    // MARK: - Private Methods

    /// JWT 토큰 만료 여부 확인
    private func isTokenExpired(_ token: String) -> Bool {
        guard let exp = extractExpiration(from: token) else {
            // 파싱 실패 시 만료로 간주
            return true
        }

        let currentTime = Date().timeIntervalSince1970
        let isExpired = currentTime > (exp - expirationBuffer)

        return isExpired
    }

    /// JWT에서 만료 시간(exp) 추출
    private func extractExpiration(from token: String) -> TimeInterval? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }

        let payloadPart = String(parts[1])

        // Base64 URL Safe → 일반 Base64로 변환 + 패딩 추가
        guard let payloadData = base64URLDecode(payloadPart) else {
            return nil
        }

        guard let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = payload["exp"] as? TimeInterval else {
            return nil
        }

        return exp
    }

    /// Base64 URL Safe 디코딩
    private func base64URLDecode(_ string: String) -> Data? {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // 패딩 추가
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        return Data(base64Encoded: base64)
    }
}
