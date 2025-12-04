//
//  FeedViewFactory.swift
//  Codive
//
//  Created by 황상환 on 12/4/25.
//

import SwiftUI

@MainActor
final class FeedViewFactory {
    private weak var feedDIContainer: FeedDIContainer?

    // MARK: - Initializer
    init(feedDIContainer: FeedDIContainer) {
        self.feedDIContainer = feedDIContainer
    }

    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .feedDetail(let feedId):
            feedDIContainer?.makeFeedDetailView(feedId: feedId)
        default:
            EmptyView()
        }
    }
}
