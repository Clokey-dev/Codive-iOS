//
//  AppRootView.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import SwiftUI
import Combine

/// 앱의 최상위 RootView
struct AppRootView: View {
    
    @StateObject var appRouter: AppRouter
    private let authDIContainer: AuthDIContainer
    private let appDIContainer: AppDIContainer
    
    @State private var authRepository: AuthRepository
    
    init(appDIContainer: AppDIContainer) {
        self._appRouter = StateObject(wrappedValue: appDIContainer.appRouter)
        self.authDIContainer = appDIContainer.makeAuthDIContainer()
        self.appDIContainer = appDIContainer
        self._authRepository = State(wrappedValue: self.authDIContainer.authRepository)
    }
    
    var body: some View {
        ZStack {
            Group {
                switch appRouter.currentAppState {
                case .splash:
                    SplashContainerView(appRouter: appRouter)

                case .auth:
                    authDIContainer.makeAuthFlowView()

                case .termsAgreement:
                    TermsAgreementView(
                        onComplete: {
                            appRouter.navigateToMain()
                        }
                    )

                case .main:
                    MainTabView(appDIContainer: appDIContainer)
                }
            }

            // 로딩 오버레이
            if appRouter.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onOpenURL { url in
            handleDeepLink(url: url)
        }
    }
    
    // MARK: - Deep Link Handler
    private func handleDeepLink(url: URL) {
        guard url.scheme == "codive",
              url.host == "oauth",
              url.path == "/callback" else {
            print("Invalid deep link format: \(url)")
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            print("Failed to parse URL components or query items.")
            return
        }

        var accessToken: String?
        var refreshToken: String?

        for item in queryItems {
            if item.name == "accessToken" {
                accessToken = item.value
            } else if item.name == "refreshToken" {
                refreshToken = item.value
            }
        }

        guard let unwrappedAccessToken = accessToken,
              let unwrappedRefreshToken = refreshToken else {
            print("Access token or refresh token missing in deep link.")
            // Potentially show an error to the user or log
            return
        }

        Task {
            do {
                try await authRepository.saveTokens(accessToken: unwrappedAccessToken, refreshToken: unwrappedRefreshToken)

                // 로딩 표시
                appRouter.showLoading()

                // 회원 상태 확인
                let status = try await authRepository.checkAuthStatus()

                switch status {
                case .notAgreed:
                    appRouter.navigateToTerms()
                case .registered:
                    appRouter.navigateToMain()
                }
            } catch {
                // 실패 시에도 일단 메인으로
                appRouter.navigateToMain()
            }
        }
    }
}
