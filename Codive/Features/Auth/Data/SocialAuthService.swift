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
    
    // MARK: - Kakao Login
    func kakaoLogin() async -> AuthResult {
        return await withCheckedContinuation { continuation in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { _, error in
                    if let error = error {
                        self.handleKakaoError(error, continuation: continuation)
                    } else {
                        self.fetchKakaoUserInfo(continuation: continuation)
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { _, error in
                    if let error = error {
                        self.handleKakaoError(error, continuation: continuation)
                    } else {
                        self.fetchKakaoUserInfo(continuation: continuation)
                    }
                }
            }
        }
    }
    
    private func fetchKakaoUserInfo(continuation: CheckedContinuation<AuthResult, Never>) {
        UserApi.shared.me { user, error in
            if error != nil {
                continuation.resume(returning: .failure(.userInfoError))
            } else if let user = user {
                let authUser = AuthUser(
                    id: "\(user.id ?? 0)",
                    email: user.kakaoAccount?.email,
                    name: user.kakaoAccount?.profile?.nickname,
                    provider: .kakao
                )
                continuation.resume(returning: .success(authUser))
            } else {
                continuation.resume(returning: .failure(.userInfoError))
            }
        }
    }
    
    private func handleKakaoError(_ error: Error, continuation: CheckedContinuation<AuthResult, Never>) {
        if let sdkError = error as? SdkError {
            switch sdkError {
            case .ClientFailed(reason: .Cancelled, _):
                continuation.resume(returning: .failure(.cancelled))
                return
            default:
                break
            }
        }
        
        let errorMessage = error.localizedDescription.lowercased()
        
        if errorMessage.contains("cancelled") ||
           errorMessage.contains("cancel") ||
           errorMessage.contains("user_cancelled") ||
           errorMessage.contains("취소") ||
           errorMessage.contains("the operation couldn't be completed") ||
           errorMessage.contains("sdkerror error 0") {
            continuation.resume(returning: .failure(.cancelled))
        } else {
            print("카카오 로그인 에러: \(error.localizedDescription)")
            continuation.resume(returning: .failure(.networkError(error.localizedDescription)))
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
