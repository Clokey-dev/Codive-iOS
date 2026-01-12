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
        Group {
            switch appRouter.currentAppState {
            case .splash:
                SplashContainerView(appRouter: appRouter)

            case .auth:
                authDIContainer.makeAuthFlowView()

            case .main:
                MainTabView(appDIContainer: appDIContainer)
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
                
                // 🔑 디버그용 토큰 출력
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔑 [로그인 성공] JWT 토큰 저장 완료")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📌 Access Token:")
                print(unwrappedAccessToken)
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📌 Refresh Token:")
                print(unwrappedRefreshToken)
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                
                print("Tokens saved successfully from deep link.")
                appRouter.navigateToMain()
            } catch {
                print("Failed to save tokens from deep link: \(error.localizedDescription)")
                // Handle error, e.g., show an alert
            }
        }
    }
}
