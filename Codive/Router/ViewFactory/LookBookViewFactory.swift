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
        case .specificLookbook(let lookbookId, let name):
            lookBookDIContainer?.makeSpecificLookBookView(
                lookbookId: lookbookId,
                name: name
            )
        case .addCodi(let lookBookId):
            lookBookDIContainer?.makeAddCodiView(lookBookId: lookBookId)
        case .addCodiDetail:
            lookBookDIContainer?.makeAddCodiDetailView()
        case .addBeforeCodi(let coordinateId):
            lookBookDIContainer?.makeAddBeforeCodiView(coordinateId: coordinateId)
        case .codiDetail(let coordinateId):
            lookBookDIContainer?.makeCodiDetailView(coordinateId: Int64(coordinateId))
        case .editCodi(let selectedCodiData):
            lookBookDIContainer?.makeEditCodiView(
                selectedCodiData: selectedCodiData
            )
        default:
            EmptyView()
        }
    }
}
