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
    
    private var appleContinuation: CheckedContinuation<AuthResult, Never>?
    
    // MARK: - Kakao Login (OIDC via ASWebAuthenticationSession)
    func kakaoLogin() async -> AuthResult {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "KAKAO_AUTH_URL") as? String,
              let authURL = URL(string: urlString) else {
            return .failure(.unknown("Invalid auth URL configuration"))
        }

        return await withCheckedContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "codive"
            ) { callbackURL, error in
                let result = Self.handleKakaoCallback(callbackURL: callbackURL, error: error)
                continuation.resume(returning: result)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }
    }

    private static func handleKakaoCallback(callbackURL: URL?, error: Error?) -> AuthResult {
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
            let authUser = AuthUser(id: "temp_kakao_user", email: nil, name: nil, provider: .kakao)
            return .success(authUser)
        } catch {
            return .failure(.keychainError(error.localizedDescription))
        }
    }
    
    // MARK: - Apple Login
    func appleLogin() async -> AuthResult {
        return await withCheckedContinuation { continuation in
            self.appleContinuation = continuation
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authController = ASAuthorizationController(authorizationRequests: [request])
            authController.delegate = self
            authController.performRequests()
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

// MARK: - Apple Sign In Delegate
extension SocialAuthService: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        defer { appleContinuation = nil }

        guard let appleContinuation = appleContinuation else { return }

        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let authUser = AuthUser(
                id: credential.user,
                email: credential.email,
                name: credential.fullName?.formatted(),
                provider: .apple
            )
            appleContinuation.resume(returning: .success(authUser))
        } else {
            appleContinuation.resume(returning: .failure(.userInfoError))
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        defer { appleContinuation = nil }

        guard let appleContinuation = appleContinuation else { return }

        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                appleContinuation.resume(returning: .failure(.cancelled))
            default:
                appleContinuation.resume(returning: .failure(.unknown(error.localizedDescription)))
            }
        } else {
            appleContinuation.resume(returning: .failure(.unknown(error.localizedDescription)))
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
