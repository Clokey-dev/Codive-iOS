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
    private let lookBookDIContainer: LookBookDIContainer

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
        self.lookBookDIContainer = appDIContainer.makeLookBookDIContainer()

        self._navigationRouter = ObservedObject(wrappedValue: appDIContainer.navigationRouter)
        let viewModel = MainTabViewModel(navigationRouter: appDIContainer.navigationRouter)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
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
            .onReceive(navigationRouter.$pendingTabSwitch) { tab in
                if let tab = tab {
                    viewModel.selectedTab = tab
                    navigationRouter.pendingTabSwitch = nil
                }
            }

            // MARK: - Success Overlay
            if let message = navigationRouter.successMessage {
                CustomSuccessView(message: message)
                    .ignoresSafeArea()
                    .zIndex(100)
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - Computed Properties

    /// 상단 네비게이션 바를 표시할지 여부
    private var shouldShowTopBar: Bool {
        // destination이 표시 중인 경우: 목적지에 따라 상단바를 숨길 수 있음
        if let destination = navigationRouter.currentDestination {
            switch destination {
            case .lookbook, .specificLookbook, .addCodi, .addCodiDetail, .addBeforeCodi, .codiDetail, .editCodi:
                return false
            default:
                break
            }
        }

        // 기본 규칙: Add 탭에서만 상단바 숨김
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

        // LookBook Flow
        case .lookbook, .specificLookbook, .addCodi, .addCodiDetail, .addBeforeCodi, .codiDetail, .editCodi:
            lookBookDIContainer.lookBookViewFactory.makeView(for: destination)

        default:
            EmptyView()
        }
    }
}
