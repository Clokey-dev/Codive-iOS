//
//  SplashViewModel.swift
//  Codive
//
//  Created by 황상환 on 1/14/26.
//

import Foundation

// MARK: - SplashViewModel

@MainActor
final class SplashViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var displayedText: String = ""

    // MARK: - Private Properties

    private let fullText: String = "Codive"
    private let typingSpeed: Double = 0.4
    private let appRouter: AppRouter

    private let tokenService: TokenServiceProtocol
    private let authAPIService: AuthAPIServiceProtocol
    private let profileAPIService: ProfileAPIServiceProtocol
    private let keychainManager: KeychainManager

    // MARK: - Initializer

    init(
        appRouter: AppRouter,
        tokenService: TokenServiceProtocol = TokenService(),
        authAPIService: AuthAPIServiceProtocol = AuthAPIService(),
        profileAPIService: ProfileAPIServiceProtocol = ProfileAPIService(),
        keychainManager: KeychainManager = KeychainManager.shared
    ) {
        self.appRouter = appRouter
        self.tokenService = tokenService
        self.authAPIService = authAPIService
        self.profileAPIService = profileAPIService
        self.keychainManager = keychainManager
    }

    // MARK: - Public Methods

    func startAnimation() async {
        await performTypingAnimation()
        await checkAutoLogin()
    }

    // MARK: - Private Methods

    private func performTypingAnimation() async {
        for i in 1...fullText.count {
            let endIndex = fullText.index(fullText.startIndex, offsetBy: i)
            displayedText = String(fullText[..<endIndex])

            do {
                try await Task.sleep(for: .seconds(typingSpeed))
            } catch {
                return
            }
        }

        // 애니메이션 종료 후 대기
        try? await Task.sleep(for: .seconds(0.5))
    }

    private func checkAutoLogin() async {
        // 임시 자동 로그인 해제 (토큰이 있어도 로그인 화면으로 이동)
//        appRouter.finishSplash()
//        return

        #if DEBUG
        print("[Splash] 자동 로그인 체크 시작")
        #endif

        // 1. 키체인에 토큰이 있는지 확인
        guard tokenService.hasValidTokens() else {
            #if DEBUG
            print("[Splash] 저장된 토큰 없음 → 로그인 화면으로 이동")
            #endif
            appRouter.finishSplash()
            return
        }

        #if DEBUG
        print("[Splash] 토큰 존재 확인 완료")
        #endif

        // 2. Access Token 유효성 검사
        if !tokenService.isAccessTokenExpired() {
            #if DEBUG
            print("[Splash] Access Token 유효 → 메인 진입 시도")
            #endif
            await proceedWithValidToken()
            return
        }

        #if DEBUG
        print("[Splash] Access Token 만료됨")
        #endif

        // 3. Refresh Token 유효성 검사
        if tokenService.isRefreshTokenExpired() {
            #if DEBUG
            print("[Splash] Refresh Token 만료됨 → 토큰 삭제 후 로그인 화면으로 이동")
            #endif
            clearTokensAndGoToAuth()
            return
        }

        // 4. 토큰 재발급
        #if DEBUG
        print("[Splash] Refresh Token 유효 → 토큰 재발급 시도")
        #endif
        await reissueTokens()
    }

    private func reissueTokens() async {
        guard let refreshToken = tokenService.getRefreshToken() else {
            #if DEBUG
            print("[Splash] Refresh Token 가져오기 실패 → 로그인 화면으로 이동")
            #endif
            clearTokensAndGoToAuth()
            return
        }

        do {
            let tokenPair = try await authAPIService.reissueTokens(refreshToken: refreshToken)
            try? keychainManager.saveAccessToken(tokenPair.accessToken)
            try? keychainManager.saveRefreshToken(tokenPair.refreshToken)
            #if DEBUG
            print("[Splash] 토큰 재발급 성공 → 메인 진입 시도")
            #endif
            await proceedWithValidToken()
        } catch {
            #if DEBUG
            print("[Splash] 토큰 재발급 실패: \(error) → 로그인 화면으로 이동")
            #endif
            clearTokensAndGoToAuth()
        }
    }

    private func proceedWithValidToken() async {
        do {
            let status = try await authAPIService.checkAuthStatus()

            switch status {
            case .notAgreed:
                appRouter.navigateToTerms()
            case .registered:
                await cacheMyProfile()
                appRouter.navigateToMain()
            }
        } catch {
            appRouter.finishSplash()
        }
    }

    private func cacheMyProfile() async {
        do {
            let profile = try await profileAPIService.fetchMyProfile()
            UserProfileStorage.save(profile)
        } catch {
            #if DEBUG
            print("[Splash] 프로필 캐싱 실패: \(error)")
            #endif
        }
    }

    private func clearTokensAndGoToAuth() {
        try? keychainManager.deleteAccessToken()
        try? keychainManager.deleteRefreshToken()
        appRouter.finishSplash()
    }
}
