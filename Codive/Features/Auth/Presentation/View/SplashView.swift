//
//  SplashView.swift
//  Codive
//
//  Created by 황상환 on 12/27/25.
//

import SwiftUI

// MARK: - SplashView (순수 UI)
struct SplashView: View {

    let displayedText: String
    let fullText: String = "Codive"
    let cursorWidth: CGFloat = 2

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ZStack(alignment: .leading) {
                // 전체 텍스트 (숨김, 레이아웃 기준용)
                HStack(alignment: .center, spacing: 2) {
                    Text(fullText)
                        .font(.codive_splash)

                    Rectangle()
                        .frame(width: cursorWidth, height: 50)
                }
                .opacity(0)

                // 타이핑 애니메이션 텍스트
                HStack(alignment: .center, spacing: 2) {
                    Text(displayedText)
                        .font(.codive_splash)
                        .foregroundColor(Color.Codive.main0)

                    Rectangle()
                        .fill(Color.Codive.main0)
                        .frame(width: cursorWidth, height: 50)
                }
            }
        }
    }
}

// MARK: - SplashContainerView 
struct SplashContainerView: View {

    @StateObject private var viewModel: SplashViewModel

    init(appRouter: AppRouter) {
        _viewModel = StateObject(wrappedValue: SplashViewModel(appRouter: appRouter))
    }

    var body: some View {
        SplashView(displayedText: viewModel.displayedText)
            .task {
                await viewModel.startAnimation()
            }
    }
}

// MARK: - SplashViewModel (타이핑 애니메이션 + 자동 로그인)
@MainActor
final class SplashViewModel: ObservableObject {

    @Published var displayedText: String = ""

    private let fullText: String = "Codive"
    private let typingSpeed: Double = 0.4
    private let appRouter: AppRouter

    // 자동 로그인 관련 서비스
    private let tokenService: TokenServiceProtocol
    private let authAPIService: AuthAPIServiceProtocol
    private let keychainManager: KeychainManager

    init(
        appRouter: AppRouter,
        tokenService: TokenServiceProtocol = TokenService(),
        authAPIService: AuthAPIServiceProtocol = AuthAPIService(),
        keychainManager: KeychainManager = KeychainManager.shared
    ) {
        self.appRouter = appRouter
        self.tokenService = tokenService
        self.authAPIService = authAPIService
        self.keychainManager = keychainManager
    }

    func startAnimation() async {
        // 타이핑 애니메이션
        for i in 1...fullText.count {
            let endIndex = fullText.index(fullText.startIndex, offsetBy: i)
            displayedText = String(fullText[..<endIndex])

            do {
                try await Task.sleep(for: .seconds(typingSpeed))
            } catch {
                return
            }
        }

        // 애니메이션 종료 후 0.5초 대기
        do {
            try await Task.sleep(for: .seconds(0.5))
        } catch {
            return
        }

        // 자동 로그인 체크
        await checkAutoLogin()
    }

    // MARK: - Auto Login Logic

    private func checkAutoLogin() async {
        print("🔐 [Splash] 자동 로그인 체크 시작")

        // 1. 키체인에 토큰이 있는지 확인
        guard tokenService.hasValidTokens() else {
            print("📭 [Splash] 저장된 토큰 없음 → 로그인 화면으로")
            appRouter.finishSplash()
            return
        }

        print("🔑 [Splash] 저장된 토큰 발견")

        // 2. Access Token 유효성 검사
        if !tokenService.isAccessTokenExpired() {
            print("✅ [Splash] Access Token 유효 → 상태 확인")
            await proceedWithValidToken()
            return
        }

        print("⏰ [Splash] Access Token 만료됨 → 재발급 시도")

        // 3. Refresh Token 유효성 검사
        if tokenService.isRefreshTokenExpired() {
            print("⏰ [Splash] Refresh Token도 만료됨 → 로그인 화면으로")
            clearTokensAndGoToAuth()
            return
        }

        // 4. 토큰 재발급
        await reissueTokens()
    }

    private func reissueTokens() async {
        guard let refreshToken = tokenService.getRefreshToken() else {
            clearTokensAndGoToAuth()
            return
        }

        let result = await authAPIService.reissueTokens(refreshToken: refreshToken)

        switch result {
        case .success(let tokenPair):
            print("✅ [Splash] 토큰 재발급 성공")
            // 새 토큰 저장
            try? keychainManager.saveAccessToken(tokenPair.accessToken)
            try? keychainManager.saveRefreshToken(tokenPair.refreshToken)
            // 상태 확인 진행
            await proceedWithValidToken()

        case .failure(let error):
            print("❌ [Splash] 토큰 재발급 실패: \(error)")
            clearTokensAndGoToAuth()
        }
    }

    private func proceedWithValidToken() async {
        // 회원 상태 확인
        let statusResult = await authAPIService.checkAuthStatus()

        switch statusResult {
        case .success(let status):
            switch status {
            case .notAgreed:
                print("📋 [Splash] 약관 동의 필요 → TermsAgreementView로")
                appRouter.navigateToTerms()
            case .registered:
                print("✅ [Splash] 가입 완료 → 메인으로")
                appRouter.navigateToMain()
            }

        case .failure(let error):
            print("❌ [Splash] 상태 확인 실패: \(error)")
            // 실패 시 로그인 화면으로
            appRouter.finishSplash()
        }
    }

    private func clearTokensAndGoToAuth() {
        print("🗑️ [Splash] 토큰 삭제 → 로그인 화면으로")
        try? keychainManager.deleteAccessToken()
        try? keychainManager.deleteRefreshToken()
        appRouter.finishSplash()
    }
}

// MARK: - Preview
#Preview {
    SplashView(displayedText: "Codi")
}
