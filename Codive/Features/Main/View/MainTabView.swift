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
    private let closetDIContainer: ClosetDIContainer
    private let feedDIContainer: FeedDIContainer
    private let searchDIContainer: SearchDIContainer
    private let notificationDIContainer: NotificationDIContainer
    private let commentDIContainer: CommentDIContainer

    // MARK: - Initializer
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        self.addDIContainer = appDIContainer.makeAddDIContainer()
        self.homeDIContainer = appDIContainer.makeHomeDIContainer()
        self.closetDIContainer = appDIContainer.closetDIContainer
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
        NavigationStack(path: $navigationRouter.path) {
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
                            ClosetView(closetDIContainer: closetDIContainer)
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
                    TabBar(selectedTab: $viewModel.selectedTab)
                        .zIndex(shouldShowTabBar ? 1 : 0)
                        .allowsHitTesting(shouldShowTabBar)
                }
            }
            .navigationDestination(for: AppDestination.self) { destination in
                destinationView(for: destination)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .environmentObject(navigationRouter)
    }
    
    // MARK: - Computed Properties

    /// 상단 네비게이션 바를 표시할지 여부
    private var shouldShowTopBar: Bool {
        return viewModel.selectedTab != .add
    }

    /// 하단 탭 바를 표시할지 여부
    private var shouldShowTabBar: Bool {
        navigationRouter.path.isEmpty
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
            
        case .wardrobeFavorite(let items):
            FavoriteByCategoryView(items: items)            
        case .wardrobeItemStats(let stats):
            ItemDataView(stats: stats)
        case .wardrobeUsage(let stats):
            WearingDataView(stats: stats)
            
        case .feedDetail(let feedId):
            feedDIContainer.makeFeedDetailView(feedId: feedId)
        case .comment(let feedId):
            commentDIContainer.makeCommentView(feedId: feedId)
        case .editCategory:
            homeDIContainer.makeEditCategoryView()
        case .codiBoard:
            homeDIContainer.makeCodiBoardView()
        case .myCloset:
            closetDIContainer.makeMyClosetView()
        case .clothDetail, .clothEdit:
            closetDIContainer.closetViewFactory.makeView(for: destination)

        // Add Flow
        case .recordAdd, .clothPhotoSelect, .photoEdit, .photoEditForCloth, .recordDetail, .photoTag, .clothAdd:
            addDIContainer.addViewFactory.makeView(for: destination)

        default:
            EmptyView()
        }
    }
}
