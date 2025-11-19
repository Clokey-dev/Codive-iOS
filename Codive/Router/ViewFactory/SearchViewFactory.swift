//
//  SearchViewFactory.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import SwiftUI

@MainActor
final class SearchViewFactory {
    private weak var searchDIContainer: SearchDIContainer?
    
    // MARK: - Initializer
    init(searchDIContainer: SearchDIContainer) {
        self.searchDIContainer = searchDIContainer
    }
    
    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .search:
            searchDIContainer?.makeSearchView()
        case .searchResult(let query):
            searchDIContainer?.makeSearchResultView(initialQuery: query)
        default:
            EmptyView()
        }
    }
}
