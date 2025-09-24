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
    private let authRepository: AuthRepository
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Initializer
    init(
        appRouter: AppRouter,
        navigationRouter: NavigationRouter,
        authRepository: AuthRepository
    ) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
        self.authRepository = authRepository
    }
    
    // MARK: - Actions
    func kakaoLoginButtonTapped() async {
        isLoading = true
        errorMessage = nil
        
        let result = await authRepository.socialLogin(provider: .kakao)  // Repository 사용
        
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
        
        let result = await authRepository.socialLogin(provider: .apple)  // Repository 사용
        
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
    
    // MARK: - Navigation Actions
    func navigateToLogin() {
        navigationRouter.navigate(to: .login)
    }
    
    func navigateToSignup() {
        navigationRouter.navigate(to: .signup)
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
