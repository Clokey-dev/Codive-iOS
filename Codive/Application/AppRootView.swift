//
//  AppRootView.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import SwiftUI

/// 앱의 최상위 RootView
struct AppRootView: View {
    
    @StateObject var appRouter: AppRouter
    private let authDIContainer: AuthDIContainer
    private let appDIContainer: AppDIContainer
    
    init(appDIContainer: AppDIContainer) {
        self._appRouter = StateObject(wrappedValue: appDIContainer.appRouter)
        self.authDIContainer = appDIContainer.makeAuthDIContainer()
        self.appDIContainer = appDIContainer
    }
    
    var body: some View {
        switch appRouter.currentAppState {
        case .auth:
            authDIContainer.makeAuthFlowView()
        case .main:
            MainTabView(appDIContainer: appDIContainer)
        }
    }
}
