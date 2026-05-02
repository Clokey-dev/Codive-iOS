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
    private let authAPIService: AuthAPIServiceProtocol
    private let profileAPIService: ProfileAPIServiceProtocol

    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var identifiableLoginURL: IdentifiableURL?
    
    // MARK: - Initializer
    init(
        appRouter: AppRouter,
        navigationRouter: NavigationRouter,
        authRepository: AuthRepository,
        authAPIService: AuthAPIServiceProtocol,
        profileAPIService: ProfileAPIServiceProtocol = ProfileAPIService()
    ) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
        self.authRepository = authRepository
        self.authAPIService = authAPIService
        self.profileAPIService = profileAPIService
    }
    
    // MARK: - Actions
    func kakaoLoginButtonTapped() async {
        isLoading = true
        errorMessage = nil

        let result = await authRepository.socialLogin(provider: .kakao)

        isLoading = false

        switch result {
        case .success(let user):
            #if DEBUG
            print("[Auth] 카카오 로그인 성공: \(user.name ?? "Unknown") (\(user.id))")
            #endif
            await proceedAfterLogin()

        case .failure(let error):
            switch error {
            case .cancelled:
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
            #if DEBUG
            print("[Auth] 애플 로그인 성공: \(user.name ?? "Unknown") (\(user.id))")
            #endif
            await proceedAfterLogin()

        case .failure(let error):
            switch error {
            case .cancelled:
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
                await cacheMyProfile()
                await sendFCMTokenToServer()
                appRouter.navigateToMain()
            }
        } catch {
            errorMessage = "회원 상태 확인에 실패했습니다."
        }
    }

    private func cacheMyProfile() async {
        do {
            let profile = try await profileAPIService.fetchMyProfile()
            UserProfileStorage.save(profile)
        } catch {
            #if DEBUG
            print("[Auth] 프로필 캐싱 실패: \(error)")
            #endif
        }
    }

    private func sendFCMTokenToServer() async {
        guard let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") else { return }

        do {
            try await authAPIService.renewDeviceToken(deviceToken: fcmToken)
        } catch {
            #if DEBUG
            print("[Push] FCM 토큰 서버 전송 실패: \(error.localizedDescription)")
            #endif
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
