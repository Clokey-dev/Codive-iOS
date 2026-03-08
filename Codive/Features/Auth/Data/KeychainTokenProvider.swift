//
//  KeychainTokenProvider.swift
//  Codive
//
//  Created by 황상환 on 1/4/26.
//

import Foundation
import CodiveAPI
import Kingfisher

// MARK: - Token Refresh Manager (Actor)

/// 토큰 자동 재발급을 관리하는 Actor
/// 동시에 여러 API 요청이 토큰 재발급을 시도할 때 한 번만 실행되도록 보장
actor TokenRefreshManager {

    static let shared = TokenRefreshManager()

    private var refreshTask: Task<String?, Error>?
    private let tokenService = TokenService()
    private let keychainManager = KeychainManager.shared

    /// 유효한 access token을 반환. 만료 시 자동으로 재발급 시도.
    func getValidToken() async -> String? {
        // 1. access token이 유효하면 그대로 반환
        if !tokenService.isAccessTokenExpired(),
           let token = tokenService.getAccessToken() {
            return token
        }

        // 2. 이미 재발급 진행 중이면 그 결과를 기다림
        if let existingTask = refreshTask {
            return try? await existingTask.value
        }

        // 3. refresh token도 만료됐으면 재발급 불가
        guard !tokenService.isRefreshTokenExpired(),
              let refreshToken = tokenService.getRefreshToken() else {
            await notifyRefreshTokenExpired()
            return nil
        }

        // 4. 재발급 실행
        let task = Task<String?, Error> {
            defer { refreshTask = nil }

            do {
                let authService = AuthAPIService(tokenProvider: PassthroughTokenProvider())
                let tokenPair = try await authService.reissueTokens(refreshToken: refreshToken)

                try? keychainManager.saveAccessToken(tokenPair.accessToken)
                try? keychainManager.saveRefreshToken(tokenPair.refreshToken)

                #if DEBUG
                print("[TokenRefresh] 토큰 재발급 성공")
                #endif
                return tokenPair.accessToken
            } catch {
                #if DEBUG
                print("[TokenRefresh] 토큰 재발급 실패: \(error)")
                #endif
                await notifyRefreshTokenExpired()
                return nil
            }
        }

        refreshTask = task
        return try? await task.value
    }

    /// refresh token 만료 또는 재발급 실패 시 로그아웃 알림
    @MainActor
    private func notifyRefreshTokenExpired() {
        #if DEBUG
        print("[TokenRefresh] 로그아웃 필요 - refresh token 만료 또는 재발급 실패")
        #endif
        try? KeychainManager.shared.clearAllTokens()
        LocalDataCleaner.clearAll()
        NotificationCenter.default.post(name: .tokenRefreshFailed, object: nil)
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let tokenRefreshFailed = Notification.Name("tokenRefreshFailed")
}

// MARK: - Keychain Token Provider

final class KeychainTokenProvider: TokenProvider, @unchecked Sendable {

    func getValidToken() async -> String? {
        await TokenRefreshManager.shared.getValidToken()
    }
}

// MARK: - Passthrough Token Provider

/// 토큰 재발급 API 호출 시 사용하는 빈 TokenProvider (인증 헤더 불필요)
final class PassthroughTokenProvider: TokenProvider {

    func getValidToken() async -> String? {
        nil
    }
}
