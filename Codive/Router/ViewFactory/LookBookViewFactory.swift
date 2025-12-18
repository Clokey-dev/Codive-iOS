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
        case .addCodi(let lookbookId, let selectedCodiData):
            lookBookDIContainer?.makeAddCodiView(lookbookId: lookbookId, selectedCodiData: selectedCodiData)
        case .addCodiDetail:
            lookBookDIContainer?.makeAddCodiDetailView()
        case .addBeforeCodi(let lookbookId):
            lookBookDIContainer?.makeAddBeforeCodiView(lookbookId: lookbookId)
        case .codiDetail(let codiId):
                lookBookDIContainer?.makeCodiDetailView(codiId: codiId)
        default:
            EmptyView()
        }
    }
}
