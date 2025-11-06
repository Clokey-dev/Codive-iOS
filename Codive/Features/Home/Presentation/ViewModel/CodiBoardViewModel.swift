//
//  CodiBoardViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

@MainActor
final class CodiBoardViewModel: ObservableObject {
    @Published var isConfirmed: Bool = false
    
    private let navigationRouter: NavigationRouter
    
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    func handleBackTap() {
        print("뒤로가기 tapped")
        navigationRouter.navigateBack()
    }

    func handleConfirmCodi() {
        print("이 코디로 결정하기 tapped")
        isConfirmed = true
    }
}
