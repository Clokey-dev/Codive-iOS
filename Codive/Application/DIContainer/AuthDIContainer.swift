//
//  AuthDIContainer.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation

@MainActor
final class AuthDIContainer {
    
    // MARK: - Properties
    private let appRouter: AppRouter
    
    // MARK: - Routers
    lazy var navigationRouter = NavigationRouter()
    
    // MARK: - Initializer
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
}
