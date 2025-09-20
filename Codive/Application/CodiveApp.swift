//
//  CodiveApp.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI

@main
struct CodiveApp: App {

    let appDIContainer = AppDIContainer()

    var body: some Scene {
        WindowGroup {
            AppRootView(appDIContainer: appDIContainer)
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
            // TODO: Main 플로우를 위한 View 연결
            Text("로그인 성공! 메인 화면입니다.")
        }
    }
}
