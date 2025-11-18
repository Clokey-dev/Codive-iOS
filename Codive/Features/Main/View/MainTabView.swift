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
    private let searchDIContainer: SearchDIContainer
    private let alarmDIContainer: AlarmDIContainer
    
    // MARK: - Initializer
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        self.addDIContainer = appDIContainer.makeAddDIContainer()
        self.homeDIContainer = appDIContainer.makeHomeDIContainer()
        self.searchDIContainer = appDIContainer.makeSearchDIContainer()
        self.alarmDIContainer = appDIContainer.makeAlarmDIContainer()
        
        self._navigationRouter = ObservedObject(wrappedValue: appDIContainer.navigationRouter)
        let viewModel = MainTabViewModel(navigationRouter: appDIContainer.navigationRouter)
        self._viewModel = StateObject(wrappedValue: viewModel)
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
                .overlay {
                    if let destination = navigationRouter.currentDestination {
                        destinationView(for: destination)
                            .transition(.move(edge: .trailing))
                    }
                }
                
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
        viewModel.selectedTab != .add &&
        !(viewModel.selectedTab == .home && !navigationRouter.path.isEmpty)
    }
    
    private var showSearchButton: Bool {
        true
    }
    
    private var showNotificationButton: Bool {
        true
    }
    
    // MARK: - Destination View Builder (추가)
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .search:
            searchDIContainer.makeSearchView()
        case .alarm:
            alarmDIContainer.makeAlarmView()
            
        default:
            EmptyView()
        }
    }
}
