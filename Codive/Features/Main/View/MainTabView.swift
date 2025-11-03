//
//  MainTabView.swift
//  Codive
//
//  Created by 황상환 on 9/22/25.
//

import SwiftUI

struct MainTabView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = MainTabViewModel()
    @ObservedObject private var navigationRouter: NavigationRouter
    private let appDIContainer: AppDIContainer
    private let addDIContainer: AddDIContainer
    
    // MARK: - Initializer
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        self.addDIContainer = appDIContainer.makeAddDIContainer()
        self.navigationRouter = appDIContainer.navigationRouter
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
                        HomeView()
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
                if navigationRouter.currentDestination == nil ||
                   navigationRouter.currentDestination?.shouldCoverTabBar == false {
                    TabBar(selectedTab: $viewModel.selectedTab)
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
