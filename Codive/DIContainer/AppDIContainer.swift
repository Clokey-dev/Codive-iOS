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

    init() {
        // Router 간 의존성 설정
        appRouter.setNavigationRouter(navigationRouter)
    }

    // MARK: - Domain DIContainers
    lazy var sharedDIContainer = SharedDIContainer()
    lazy var closetDIContainer = ClosetDIContainer(navigationRouter: navigationRouter)
    lazy var profileDIContainer = ProfileDIContainer(navigationRouter: navigationRouter)
    lazy var authDIContainer = AuthDIContainer(appRouter: appRouter, navigationRouter: navigationRouter)

    // MARK: - Feature DIContainers
    
    func makeAddDIContainer() -> AddDIContainer {
        return AddDIContainer(
            navigationRouter: navigationRouter,
            feedDIContainer: makeFeedDIContainer(),
            closetDIContainer: closetDIContainer,
            sharedDIContainer: sharedDIContainer
        )
    }
    
    func makeSettingDIContainer() -> SettingDIContainer {
        return SettingDIContainer(appRouter: appRouter, navigationRouter: navigationRouter, profileDIContainer: profileDIContainer, authDIContainer: authDIContainer)
    }
    
    func makeReportDIContainer() -> ReportDIContainer {
        return ReportDIContainer(appRouter: appRouter, navigationRouter: navigationRouter)
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

    func makeFeedDIContainer() -> FeedDIContainer {
        return FeedDIContainer(navigationRouter: navigationRouter)
    }
    
    func makeCommentDIContainer() -> CommentDIContainer {
        return CommentDIContainer(navigationRouter: navigationRouter)
    }

    func makeProfileDIContainer() -> ProfileDIContainer {
        return ProfileDIContainer(navigationRouter: navigationRouter)
    }
}
