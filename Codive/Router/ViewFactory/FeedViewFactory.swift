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
    private var otherProfileViewModelCache: [Int: OtherProfileViewModel] = [:]

    // MARK: - Initializer
    init(feedDIContainer: FeedDIContainer, navigationRouter: NavigationRouter) {
        self.feedDIContainer = feedDIContainer
        self.navigationRouter = navigationRouter
    }

    // MARK: - Methods

    private func getOrCreateOtherProfileView(userId: Int, profileDIContainer: ProfileDIContainer) -> OtherProfileView {
        let viewModel: OtherProfileViewModel
        if let cachedViewModel = otherProfileViewModelCache[userId] {
            viewModel = cachedViewModel
        } else {
            viewModel = profileDIContainer.makeOtherProfileViewModel(memberId: userId)
            otherProfileViewModelCache[userId] = viewModel
        }

        return OtherProfileView(
            viewModel: viewModel,
            navigationRouter: navigationRouter
        )
    }

    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .feedDetail(let feedId):
            feedDIContainer?.makeFeedDetailView(feedId: feedId)
        case .otherProfile(let userId):
            if let profileDIContainer = feedDIContainer?.profileDIContainer {
                getOrCreateOtherProfileView(userId: userId, profileDIContainer: profileDIContainer)
            } else {
                EmptyView()
            }
        default:
            EmptyView()
        }
    }
}
