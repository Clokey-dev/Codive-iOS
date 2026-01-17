//
//  AuthRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import Foundation
import CodiveAPI

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
        await socialAuthService.logout()
    }

    func saveTokens(accessToken: String, refreshToken: String) async throws {
        try KeychainManager.shared.saveAccessToken(accessToken)
        try KeychainManager.shared.saveRefreshToken(refreshToken)
    }
}
