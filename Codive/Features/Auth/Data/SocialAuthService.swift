//
//  SocialAuthService.swift
//  Codive
//
//  Created by 황상환 on 9/21/25.
//

import Foundation
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import AuthenticationServices
import UIKit

// MARK: - Social Auth Service Protocol
protocol SocialAuthServiceProtocol {
    func kakaoLogin() async -> AuthResult
    func appleLogin() async -> AuthResult
    func logout() async
}

// MARK: - Social Auth Service Implementation
@MainActor
final class SocialAuthService: NSObject, SocialAuthServiceProtocol {

    // MARK: - Kakao Login (OIDC via ASWebAuthenticationSession)
    func kakaoLogin() async -> AuthResult {
        return await socialLogin(
            urlKey: "KAKAO_AUTH_URL",
            provider: .kakao
        )
    }

    // MARK: - Apple Login (OIDC via ASWebAuthenticationSession)
    func appleLogin() async -> AuthResult {
        return await socialLogin(
            urlKey: "APPLE_AUTH_URL",
            provider: .apple
        )
    }

    // MARK: - Common OAuth Login
    private func socialLogin(urlKey: String, provider: AuthProvider) async -> AuthResult {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: urlKey) as? String,
              let authURL = URL(string: urlString) else {
            return .failure(.unknown("Invalid auth URL configuration"))
        }

        return await withCheckedContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "codive"
            ) { callbackURL, error in
                let result = Self.handleOAuthCallback(
                    callbackURL: callbackURL,
                    error: error,
                    provider: provider
                )
                continuation.resume(returning: result)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }

    private static func handleOAuthCallback(
        callbackURL: URL?,
        error: Error?,
        provider: AuthProvider
    ) -> AuthResult {
        if let error = error {
            if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
                return .failure(.cancelled)
            }
            return .failure(.networkError(error.localizedDescription))
        }

        guard let callbackURL = callbackURL,
              let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return .failure(.tokenParsingError)
        }

        guard let accessToken = queryItems.first(where: { $0.name == "accessToken" })?.value,
              let refreshToken = queryItems.first(where: { $0.name == "refreshToken" })?.value else {
            return .failure(.tokenParsingError)
        }

        do {
            try KeychainManager.shared.saveAccessToken(accessToken)
            try KeychainManager.shared.saveRefreshToken(refreshToken)
            let authUser = AuthUser(id: "temp_\(provider.rawValue)_user", email: nil, name: nil, provider: provider)
            return .success(authUser)
        } catch {
            return .failure(.keychainError(error.localizedDescription))
        }
    }
    
    // MARK: - Logout
    func logout() async {
        // 카카오 로그아웃
        await withCheckedContinuation { continuation in
            UserApi.shared.logout { error in
                #if DEBUG
                if let error = error {
                    print("[Auth] 카카오 로그아웃 실패: \(error)")
                } else {
                    print("[Auth] 카카오 로그아웃 성공")
                }
                #endif
                continuation.resume()
            }
        }
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension SocialAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
            
        return window
    }
}
