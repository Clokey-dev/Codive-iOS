//
//  LookBookViewFactory.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import SwiftUI

@MainActor
final class LookBookViewFactory {
    private weak var lookBookDIContainer: LookBookDIContainer?
    
    // MARK: - Initializer
    init(lookBookDIContainer: LookBookDIContainer) {
        self.lookBookDIContainer = lookBookDIContainer
    }
    
    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .lookbook:
            lookBookDIContainer?.makeLookBookView()
        case .specificLookbook(let lookbookId):
            lookBookDIContainer?.makeSpecificLookBookView(lookbookId: lookbookId)
        case .addCodi(let lookbookId):
            lookBookDIContainer?.makeAddCodiView(lookbookId: lookbookId)
        default:
            EmptyView()
        }
    }
}
