//
//  OnboardingViewModel.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Properties
    private let appRouter: AppRouter
    private let navigationRouter: NavigationRouter
    private let socialAuthService: SocialAuthServiceProtocol
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Initializer
    init(
        appRouter: AppRouter,
        navigationRouter: NavigationRouter,
        socialAuthService: SocialAuthServiceProtocol
    ) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
        self.socialAuthService = socialAuthService
    }
    
    // MARK: - Actions
    func kakaoLoginButtonTapped() async {
        isLoading = true
        errorMessage = nil
        
        let result = await socialAuthService.kakaoLogin()
        
        isLoading = false
        
        switch result {
        case .success(let user):
            print("카카오 로그인 성공: \(user.name ?? "Unknown") (\(user.id))")
            appRouter.navigateToMain()
            
        case .failure(let error):
            switch error {
            case .cancelled:
                print("카카오 로그인 취소됨")
                return
            case .networkError(let message):
                if message.contains("The operation couldn't be completed") ||
                   message.contains("KakaoSDKCommon.SdkError error 0") {
                    print("카카오 로그인 취소됨 (네트워크 에러로 분류된 취소)")
                    return
                }
                errorMessage = error.localizedDescription
            default:
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func appleLoginButtonTapped() async {
        isLoading = true
        errorMessage = nil
        
        let result = await socialAuthService.appleLogin()
        
        isLoading = false
        
        switch result {
        case .success(let user):
            print("애플 로그인 성공: \(user.name ?? "Unknown") (\(user.id))")
            appRouter.navigateToMain()
            
        case .failure(let error):
            switch error {
            case .cancelled:
                print("애플 로그인 취소됨")
                return
            default:
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Legacy Method (기존 호환성 유지)
    func loginButtonTapped() {
        Task {
            await kakaoLoginButtonTapped()
        }
    }
    
    // MARK: - Helper Methods
    func clearError() {
        errorMessage = nil
    }
}
