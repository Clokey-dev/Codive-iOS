//
//  OnboardingViewModel.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Properties
    private let appRouter: AppRouter
    private let navigationRouter: NavigationRouter
    
    // MARK: - Initializer
    init(
        appRouter: AppRouter,
        navigationRouter: NavigationRouter
    ) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - Methods
    /// 로그인 버튼 탭 액션
    func loginButtonTapped() {
        // TODO: 실제 로그인 API 연동 로직
        
        // 로그인 성공 시, AppRouter를 통해 앱 상태를 .main으로 변경
        appRouter.navigateToMain()
    }
}
