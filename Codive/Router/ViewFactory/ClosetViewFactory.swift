//
//  ClosetViewFactory.swift
//  Codive
//
//  Created by 황상환 on 12/20/25.
//

import SwiftUI

@MainActor
final class ClosetViewFactory {

    // MARK: - Properties
    private weak var closetDIContainer: ClosetDIContainer?

    // MARK: - Initializer
    init(closetDIContainer: ClosetDIContainer) {
        self.closetDIContainer = closetDIContainer
    }

    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .myCloset:
            closetDIContainer?.makeMyClosetView()
        default:
            EmptyView()
        }
    }
}
