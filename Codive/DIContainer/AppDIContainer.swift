//
//  AppDIContainer.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation

@MainActor
final class AppDIContainer {
    
    // MARK: - Routers
    lazy var appRouter = AppRouter()
    lazy var navigationRouter = NavigationRouter()
    
    // MARK: - DIContainers
    func makeAuthDIContainer() -> AuthDIContainer {
        return AuthDIContainer(
                appRouter: appRouter,
                navigationRouter: navigationRouter
            )    }
    
    func makeAddDIContainer() -> AddDIContainer {
        return AddDIContainer(navigationRouter: navigationRouter)
    }
    
    func makeHomeDIContainer() -> HomeDIContainer {
        return HomeDIContainer(navigationRouter: navigationRouter)
    }
    
    func makeSearchDIContainer() -> SearchDIContainer {
        return SearchDIContainer(navigationRouter: navigationRouter)
    }
    
    func makeNotificationDIContainer() -> NotificationDIContainer {
        return NotificationDIContainer(navigationRouter: navigationRouter)
    }
    
    func makeLookBookDIContainer() -> LookBookDIContainer {
        return LookBookDIContainer(navigationRouter: navigationRouter)
    }
}
