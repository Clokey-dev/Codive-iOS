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
    lazy var viewFactory = ViewFactory(authDIContainer: self)
    
    // MARK: - Routers
    lazy var navigationRouter = NavigationRouter()
    
    // MARK: - Initializer
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    // MARK: - ViewModels
    func makeOnboardingViewModel() -> OnboardingViewModel {
        return OnboardingViewModel(
            appRouter: appRouter,
            navigationRouter: navigationRouter
        )
    }
    
    // MARK: - Views
    func makeOnboardingView() -> OnboardingView {
        return OnboardingView(viewModel: makeOnboardingViewModel())
    }
    
    func makeAuthView() -> AuthView {
        return AuthView(
            authDIContainer: self,
            viewFactory: viewFactory
        )
    }
}
