//
//  AuthFlowView.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI

struct AuthFlowView: View {

    @StateObject var navigationRouter: NavigationRouter
    private let authViewFactory: AuthViewFactory
    private let authDIContainer: AuthDIContainer

    init(
        authDIContainer: AuthDIContainer,
        authViewFactory: AuthViewFactory
    ) {
        self._navigationRouter = StateObject(wrappedValue: authDIContainer.navigationRouter)
        self.authViewFactory = authViewFactory
        self.authDIContainer = authDIContainer
    }

    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            authDIContainer.makeOnboardingView()
                .navigationDestination(for: AppDestination.self) { destination in
                    authViewFactory.makeView(for: destination)
                }
        }
    }
}
