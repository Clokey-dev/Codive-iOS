//
//  AuthView.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI

struct AuthView: View {
    
    @StateObject var navigationRouter: NavigationRouter
    private let viewFactory: ViewFactory
    private let authDIContainer: AuthDIContainer
    
    init(
        authDIContainer: AuthDIContainer,
        viewFactory: ViewFactory
    ) {
        self._navigationRouter = StateObject(wrappedValue: authDIContainer.navigationRouter)
        self.viewFactory = viewFactory
        self.authDIContainer = authDIContainer
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            authDIContainer.makeOnboardingView()
                .navigationDestination(for: Destination.self) { destination in
                    viewFactory.makeView(for: destination)
                }
        }
    }
}
