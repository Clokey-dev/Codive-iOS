//
//  CodiveApp.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI
import KakaoSDKAuth

@main
struct CodiveApp: App {

    let appDIContainer = AppDIContainer()

    init() {
        AppConfigurator.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(appDIContainer: appDIContainer)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}

/// 앱의 최상위 RootView
struct AppRootView: View {
    
    @StateObject var appRouter: AppRouter
    private let authDIContainer: AuthDIContainer
    
    init(appDIContainer: AppDIContainer) {
        self._appRouter = StateObject(wrappedValue: appDIContainer.appRouter)
        self.authDIContainer = appDIContainer.makeAuthDIContainer()
    }
    
    var body: some View {
        switch appRouter.currentAppState {
        case .auth:
            authDIContainer.makeAuthView()
        case .main:
            MainTabView()
        }
    }
}
