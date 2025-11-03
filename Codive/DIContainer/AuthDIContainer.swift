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
    let navigationRouter: NavigationRouter
    lazy var authViewFactory = AuthViewFactory(authDIContainer: self)
    
    // MARK: - Services (Data Layer)
    lazy var socialAuthService: SocialAuthServiceProtocol = SocialAuthService()
    
    // MARK: - Repositories (Domain Layer)
    lazy var authRepository: AuthRepository = AuthRepositoryImpl(
        socialAuthService: socialAuthService
    )
    
    // MARK: - Initializer
    init(appRouter: AppRouter, navigationRouter: NavigationRouter) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - ViewModels
    func makeOnboardingViewModel() -> OnboardingViewModel {
        return OnboardingViewModel(
            appRouter: appRouter,
            navigationRouter: navigationRouter,
            authRepository: authRepository
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
