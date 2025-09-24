//
//  AuthViewFactory.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import SwiftUI

@MainActor
final class AuthViewFactory {
    
    // MARK: - Properties
    private let authDIContainer: AuthDIContainer
    
    // MARK: - Initializer
    init(authDIContainer: AuthDIContainer) {
        self.authDIContainer = authDIContainer
    }
    
    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .login:
            // LoginView(viewModel: authDIContainer.makeLoginViewModel())
            Text("로그인 화면") // 임시
        case .signup:
            // SignUpView(viewModel: authDIContainer.makeSignUpViewModel())
            Text("회원가입 화면") // 임시
        case .main:
            // Main Feature에서 사용될 예정
            EmptyView()
        }
    }
}
