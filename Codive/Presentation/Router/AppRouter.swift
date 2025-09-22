//
//  AppRouter.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation
import SwiftUI

// 앱의 최상위 상태 정의 - (인증 플로우 / 메인 플로우)
enum AppState {
    case auth
    case main
}

// 상태 전환 라우터
@MainActor
final class AppRouter: ObservableObject {
    
    // MARK: - 임시 자동로그인 플래그 (나중에 삭제 예정)
    private let isAutoLoginEnabled = true
    
    @Published var currentAppState: AppState
    
    init() {
        // 임시: 자동로그인이 활성화되어 있으면 바로 메인으로
        self.currentAppState = isAutoLoginEnabled ? .main : .auth
    }
    
    func navigateToMain() {
        currentAppState = .main
    }
}
