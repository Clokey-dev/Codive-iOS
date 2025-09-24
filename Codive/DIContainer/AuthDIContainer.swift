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
    lazy var authViewFactory = AuthViewFactory(authDIContainer: self)
    
    // MARK: - Services
    lazy var socialAuthService: SocialAuthServiceProtocol = SocialAuthService()
    
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
            navigationRouter: navigationRouter,
            socialAuthService: socialAuthService
        )
    }
    
    // MARK: - Views
    func makeOnboardingView() -> OnboardingView {
        return OnboardingView(viewModel: makeOnboardingViewModel())
    }
    
    func makeAuthFlowView() -> AuthFlowView {
        return AuthFlowView(
            authDIContainer: self,
            authViewFactory: authViewFactory
        )
    }
}
