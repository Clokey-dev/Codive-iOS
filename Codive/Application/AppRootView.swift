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
    
    init(appDIContainer: AppDIContainer) {
        self._appRouter = StateObject(wrappedValue: appDIContainer.appRouter)
        self.authDIContainer = appDIContainer.makeAuthDIContainer()
    }
    
    var body: some View {
        switch appRouter.currentAppState {
        case .auth:
            authDIContainer.makeAuthFlowView()
        case .main:
//            MainTabView()
            EditCategoryView()
        }
    }
}
