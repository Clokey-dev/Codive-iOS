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
                // 에러 처리
                if let error = error {
                    if let authError = error as? ASWebAuthenticationSessionError {
                        switch authError.code {
                        case .canceledLogin:
                            continuation.resume(returning: .failure(.cancelled))
                        default:
                            continuation.resume(returning: .failure(.networkError(error.localizedDescription)))
                        }
                    } else {
                        continuation.resume(returning: .failure(.networkError(error.localizedDescription)))
                    }
                    return
                }

                // 콜백 URL에서 토큰 파싱
                guard let callbackURL = callbackURL else {
                    continuation.resume(returning: .failure(.tokenParsingError))
                    return
                }

                // URL 파라미터에서 토큰 추출
                guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let queryItems = components.queryItems else {
                    continuation.resume(returning: .failure(.tokenParsingError))
                    return
                }

                let accessToken = queryItems.first(where: { $0.name == "accessToken" })?.value
                let refreshToken = queryItems.first(where: { $0.name == "refreshToken" })?.value

                guard let accessToken = accessToken,
                      let refreshToken = refreshToken else {
                    continuation.resume(returning: .failure(.tokenParsingError))
                    return
                }

                // Keychain에 토큰 저장
                do {
                    try KeychainManager.shared.saveAccessToken(accessToken)
                    try KeychainManager.shared.saveRefreshToken(refreshToken)

                    // 성공 시 임시 사용자 정보 반환 (나중에 서버에서 받아야 함)
                    let authUser = AuthUser(
                        id: "temp_kakao_user",
                        email: nil,
                        name: nil,
                        provider: .kakao
                    )
                    continuation.resume(returning: .success(authUser))
                } catch {
                    continuation.resume(returning: .failure(.keychainError(error.localizedDescription)))
                }
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            session.start()
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
                if let error = error {
                    print("카카오 로그아웃 실패: \(error)")
                } else {
                    print("카카오 로그아웃 성공")
                }
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
        // 현재 활성 윈도우 반환
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
