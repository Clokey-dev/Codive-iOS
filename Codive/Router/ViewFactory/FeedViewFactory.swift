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
    private let navigationRouter: NavigationRouter

    // MARK: - Initializer
    init(feedDIContainer: FeedDIContainer, navigationRouter: NavigationRouter) {
        self.feedDIContainer = feedDIContainer
        self.navigationRouter = navigationRouter
    }

    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .feedDetail(let feedId):
            feedDIContainer?.makeFeedDetailView(feedId: feedId)
        case .otherProfile:
            if let profileDIContainer = feedDIContainer?.profileDIContainer {
                OtherProfileView(
                    viewModel: profileDIContainer.makeOtherProfileViewModel(),
                    navigationRouter: navigationRouter
                )
            } else {
                EmptyView()
            }
        default:
            EmptyView()
        }
    }
}
