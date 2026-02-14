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
    @Published var identifiableLoginURL: IdentifiableURL?
    
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

        let result = await authRepository.socialLogin(provider: .kakao)

        isLoading = false

        switch result {
        case .success(let user):
            print("카카오 로그인 성공: \(user.name ?? "Unknown") (\(user.id))")
            await proceedAfterLogin()

        case .failure(let error):
            switch error {
            case .cancelled:
                print("카카오 로그인 취소됨")
                return
            default:
                errorMessage = error.localizedDescription
            }
        }
    }

    func appleLoginButtonTapped() async {
        isLoading = true
        errorMessage = nil

        let result = await authRepository.socialLogin(provider: .apple)

        isLoading = false

        switch result {
        case .success(let user):
            print("애플 로그인 성공: \(user.name ?? "Unknown") (\(user.id))")
            await proceedAfterLogin()

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

    // MARK: - Private Methods
    private func proceedAfterLogin() async {
        do {
            let status = try await authRepository.checkAuthStatus()

            switch status {
            case .notAgreed:
                appRouter.navigateToTerms()
            case .registered:
                appRouter.navigateToMain()
            }
        } catch {
            errorMessage = "회원 상태 확인에 실패했습니다."
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
