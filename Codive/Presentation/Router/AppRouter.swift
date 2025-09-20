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
    @Published var currentAppState: AppState = .auth
    
    func navigateToMain() {
        currentAppState = .main
    }
}
