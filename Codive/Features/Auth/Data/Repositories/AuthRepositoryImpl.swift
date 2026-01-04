//
//  AuthRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import Foundation

// MARK: - Auth Repository Implementation
@MainActor
final class AuthRepositoryImpl: AuthRepository {

    // MARK: - Properties
    private let socialAuthService: SocialAuthServiceProtocol
    private let authAPIService: AuthAPIServiceProtocol

    // MARK: - Initializer
    init(
        socialAuthService: SocialAuthServiceProtocol,
        authAPIService: AuthAPIServiceProtocol = AuthAPIService()
    ) {
        self.socialAuthService = socialAuthService
        self.authAPIService = authAPIService
    }
    
    // MARK: - AuthRepository Implementation
    func socialLogin(provider: AuthProvider) async -> AuthResult {
        switch provider {
        case .kakao:
            return await socialAuthService.kakaoLogin()
        case .apple:
            return await socialAuthService.appleLogin()
        }
        
        // 향후 서버 연결 시 확장될 로직:
        // 1. 소셜 로그인 성공
        // 2. 서버에 사용자 정보 전송
        // 3. JWT 토큰 받아서 로컬 저장
        // 4. 최종 AuthResult 반환
    }
    
    func checkAuthStatus() async -> AuthStatusResult {
        return await authAPIService.checkAuthStatus()
    }

    func logout() async {
        await socialAuthService.logout()

        // 향후 서버 연결 시 추가될 로직:
        // 1. 서버에 로그아웃 요청
        // 2. 로컬 토큰 삭제
        // 3. 소셜 플랫폼 로그아웃
    }
}
