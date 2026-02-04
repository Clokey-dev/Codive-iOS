//
//  AppRouter.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation
import SwiftUI

// 앱의 최상위 상태 정의
enum AppState {
    case splash           // 스플래시 화면
    case auth             // 인증 플로우 (온보딩/로그인)
    case termsAgreement   // 약관 동의 화면
    case main             // 메인 플로우
}

// 상태 전환 라우터
@MainActor
final class AppRouter: ObservableObject {

    @Published var currentAppState: AppState
    @Published var isLoading: Bool = false  // 로딩 상태

    private weak var navigationRouter: NavigationRouter?

    init() {
        // 앱 시작시 스플래시부터 시작
        self.currentAppState = .splash
    }

    /// NavigationRouter 등록 (AppDIContainer에서 호출)
    func setNavigationRouter(_ router: NavigationRouter) {
        self.navigationRouter = router
    }

    func finishSplash() {
        // 스플래시 종료 후 인증 화면으로 이동
        // TODO: 로그인 상태 확인 로직 추가 (토큰 있으면 .main)
        currentAppState = .auth
    }

    func navigateToTerms() {
        isLoading = false
        currentAppState = .termsAgreement
    }

    func navigateToMain() {
        isLoading = false
        currentAppState = .main
    }

    func showLoading() {
        isLoading = true
    }

    func hideLoading() {
        isLoading = false
    }

    /// 로그아웃: 토큰 삭제 + 모든 네비게이션 리셋 + 로그인 화면으로
    func logout() {
        // 1. 모든 네비게이션 스택 제거
        navigationRouter?.navigateToRoot()

        // 2. 로그인 화면으로 상태 변경
        currentAppState = .auth
    }
}
