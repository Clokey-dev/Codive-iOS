//
//  ViewFactory.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI

@MainActor
final class ViewFactory {
    
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
            EmptyView()
        case .signup:
            Text("회원가입 화면")
        case .main:
            EmptyView()
        }
    }
}
