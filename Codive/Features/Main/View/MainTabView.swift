//
//  MainTabView.swift
//  Codive
//
//  Created by 황상환 on 9/22/25.
//

import SwiftUI

struct MainTabView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: MainTabViewModel
    @ObservedObject private var navigationRouter: NavigationRouter
    private let appDIContainer: AppDIContainer
    private let addDIContainer: AddDIContainer
    private let homeDIContainer: HomeDIContainer
    private let feedDIContainer: FeedDIContainer
    private let searchDIContainer: SearchDIContainer
    private let notificationDIContainer: NotificationDIContainer
    private let commentDIContainer: CommentDIContainer

    // MARK: - Initializer
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        self.addDIContainer = appDIContainer.makeAddDIContainer()
        self.homeDIContainer = appDIContainer.makeHomeDIContainer()
        self.feedDIContainer = appDIContainer.makeFeedDIContainer()
        self.searchDIContainer = appDIContainer.makeSearchDIContainer()
        self.notificationDIContainer = appDIContainer.makeNotificationDIContainer()
        self.commentDIContainer = appDIContainer.makeCommentDIContainer()

        self._navigationRouter = ObservedObject(wrappedValue: appDIContainer.navigationRouter)
        let viewModel = MainTabViewModel(navigationRouter: appDIContainer.navigationRouter)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 기본 탭바 UI
            VStack(spacing: 0) {
                if shouldShowTopBar {
                    TopNavigationBar(
                        showSearchButton: showSearchButton,
                        showNotificationButton: showNotificationButton,
                        onSearchTap: viewModel.handleSearchTap,
                        onNotificationTap: viewModel.handleNotificationTap
                    )
                }

                ZStack(alignment: .bottom) {
                    Group {
                        switch viewModel.selectedTab {
                        case .home:
                            HomeView(homeDIContainer: homeDIContainer)
                                .ignoresSafeArea(.all, edges: .bottom)
                        case .closet:
                            ClosetView()
                        case .add:
                            AddView(addDIContainer: addDIContainer)
                                .ignoresSafeArea(.all, edges: .bottom)
                        case .feed:
                            FeedView(viewModel: feedDIContainer.makeFeedViewModel())
                        case .profile:
                            ProfileView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // MARK: - Tab Bar
                    if shouldShowTabBar {
                        TabBar(selectedTab: $viewModel.selectedTab)
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)

            if let destination = navigationRouter.currentDestination {
                destinationView(for: destination)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: navigationRouter.currentDestination)
    }
    
    // MARK: - Computed Properties

    /// 상단 네비게이션 바를 표시할지 여부
    private var shouldShowTopBar: Bool {
        // destination은 ZStack으로 위에 덮이므로 체크하지 않음
        // Add 탭에서만 상단바 숨김
        return viewModel.selectedTab != .add
    }

    /// 하단 탭 바를 표시할지 여부
    private var shouldShowTabBar: Bool {
        // destination이 있고 탭바를 덮어야 하면 숨김
        if let destination = navigationRouter.currentDestination {
            return !destination.shouldCoverTabBar
        }

        // destination이 없으면 항상 표시
        return true
    }

    private var showSearchButton: Bool {
        true
    }

    private var showNotificationButton: Bool {
        true
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .search:
            searchDIContainer.makeSearchView()
        case .searchResult(let query):
            searchDIContainer.makeSearchResultView(initialQuery: query)
        case .notification:
            notificationDIContainer.makeNotificationView()
        case .feedDetail(let feedId):
            feedDIContainer.makeFeedDetailView(feedId: feedId)
        case .comment(let feedId):
            commentDIContainer.makeCommentView(feedId: feedId)
        case .editCategory:
            homeDIContainer.makeEditCategoryView()
        case .codiBoard:
            homeDIContainer.makeCodiBoardView()

        default:
            EmptyView()
        }
    }
}
