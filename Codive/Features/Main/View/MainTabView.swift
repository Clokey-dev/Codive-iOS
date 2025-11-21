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
    @StateObject private var searchNavigationRouter: NavigationRouter
    @StateObject private var notificationNavigationRouter: NavigationRouter
    
    private let appDIContainer: AppDIContainer
    private let addDIContainer: AddDIContainer
    private let homeDIContainer: HomeDIContainer
    private let searchDIContainer: SearchDIContainer
    private let notificationDIContainer: NotificationDIContainer
    
    // MARK: - Initializer
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        self.addDIContainer = appDIContainer.makeAddDIContainer()
        self.homeDIContainer = appDIContainer.makeHomeDIContainer()
        
        let searchContainer = appDIContainer.makeSearchDIContainer()
        let notificationContainer = appDIContainer.makeNotificationDIContainer()
        
        self.searchDIContainer = searchContainer
        self.notificationDIContainer = notificationContainer
        
        let viewModel = MainTabViewModel()
        self._viewModel = StateObject(wrappedValue: viewModel)
        
        self._searchNavigationRouter = StateObject(wrappedValue: searchContainer.navigationRouter)
        self._notificationNavigationRouter = StateObject(wrappedValue: notificationContainer.navigationRouter)
    }
    // MARK: - Body
    var body: some View {
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
                        FeedView()
                    case .profile:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // MARK: - Tab Bar
                TabBar(selectedTab: $viewModel.selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        // MARK: - Search FullScreenCover
        .fullScreenCover(
            isPresented: $viewModel.showSearch,
            onDismiss: {
                searchNavigationRouter.navigateToRoot()
            },
            content: {
                NavigationStack(path: $searchNavigationRouter.path) {
                    searchDIContainer.makeSearchView()
                        .navigationDestination(for: AppDestination.self) { destination in
                            searchDIContainer.searchViewFactory.makeView(for: destination)
                        }
                }
            }
        )
        // MARK: - Notification FullScreenCover
        .fullScreenCover(
            isPresented: $viewModel.showNotification,
            onDismiss: {
                notificationNavigationRouter.navigateToRoot()
            },
            content: {
                NavigationStack(path: $notificationNavigationRouter.path) {
                    notificationDIContainer.makeNotificationView()
                        .navigationDestination(for: AppDestination.self) { destination in
                            notificationDIContainer.notificationViewFactory.makeView(for: destination)
                        }
                }
            }
        )
    }
    
    // MARK: - Computed Properties
    private var shouldShowTopBar: Bool {
        viewModel.selectedTab != .add
    }
    
    private var showSearchButton: Bool {
        true
    }
    
    private var showNotificationButton: Bool {
        true
    }
}
