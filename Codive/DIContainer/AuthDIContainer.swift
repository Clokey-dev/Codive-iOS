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
    lazy var authAPIService: AuthAPIServiceProtocol = AuthAPIService()
    
    // MARK: - Repositories (Domain Layer)
    lazy var authRepository: AuthRepository = AuthRepositoryImpl(
        socialAuthService: socialAuthService,
        authAPIService: authAPIService,
        keychainTokenProvider: KeychainTokenProvider() 
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
            authRepository: authRepository,
            authAPIService: authAPIService
        )
    }
    
    // MARK: - Views
    func makeOnboardingView() -> OnboardingContainerView {
        return OnboardingContainerView(viewModel: self.makeOnboardingViewModel())
    }
    
    func makeAuthFlowView() -> AuthFlowView {
        return AuthFlowView(
            authDIContainer: self,
            authViewFactory: authViewFactory
        )
    }
}
