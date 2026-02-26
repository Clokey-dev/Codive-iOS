//
//  AuthRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import Foundation
import CodiveAPI
import Kingfisher

// MARK: - Auth Repository Implementation
@MainActor
final class AuthRepositoryImpl: AuthRepository {

    // MARK: - Properties
    private let socialAuthService: SocialAuthServiceProtocol
    private let authAPIService: AuthAPIServiceProtocol
    private let keychainTokenProvider: TokenProvider

    // MARK: - Initializer
    init(
        socialAuthService: SocialAuthServiceProtocol,
        authAPIService: AuthAPIServiceProtocol = AuthAPIService(),
        keychainTokenProvider: TokenProvider = KeychainTokenProvider()
    ) {
        self.socialAuthService = socialAuthService
        self.authAPIService = authAPIService
        self.keychainTokenProvider = keychainTokenProvider
    }
    
    // MARK: - AuthRepository Implementation
    func socialLogin(provider: AuthProvider) async -> AuthResult {
        switch provider {
        case .kakao:
            return await socialAuthService.kakaoLogin()
        case .apple:
            return await socialAuthService.appleLogin()
        }
    }
    
    func checkAuthStatus() async throws -> RegisterStatus {
        return try await authAPIService.checkAuthStatus()
    }

    func logout() async {
        // 서버에 로그아웃 요청 (Redis 리프레시 토큰 삭제)
        try? await authAPIService.logoutUser()
        // 소셜 로그아웃 (카카오/애플)
        await socialAuthService.logout()
        // 로컬 키체인 토큰 삭제
        try? KeychainManager.shared.clearAllTokens()
        // 로컬 캐시 데이터 삭제
        clearLocalData()
    }

    func deactivateAccount() async throws {
        // 서버에 비활성화 요청 (15일 뒤 자동 탈퇴)
        try await authAPIService.deactivateAccount()
        // 소셜 로그아웃
        await socialAuthService.logout()
        // 로컬 키체인 토큰 삭제
        try? KeychainManager.shared.clearAllTokens()
        // 로컬 캐시 데이터 삭제
        clearLocalData()
    }

    // MARK: - Local Data Cleanup
    private func clearLocalData() {
        // UserDefaults 캐시 삭제 (카테고리, 프로필 등)
        UserDefaults.standard.removeObject(forKey: "SavedCategories")
        UserProfileStorage.clear()
        // Kingfisher 이미지 캐시 삭제
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        // URL 캐시 삭제
        URLCache.shared.removeAllCachedResponses()
    }

    func saveTokens(accessToken: String, refreshToken: String) async throws {
        try KeychainManager.shared.saveAccessToken(accessToken)
        try KeychainManager.shared.saveRefreshToken(refreshToken)
    }
}
