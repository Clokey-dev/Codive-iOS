import SwiftUI

struct MainTabView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = MainTabViewModel()
    
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
            
            // MARK: - Main Content Area
            ZStack(alignment: .bottom) {
                Group {
                    switch viewModel.selectedTab {
                    case .home:
                        HomeView()
                    case .closet:
                        ClosetView()
                    case .add:
                        AddView()
                    case .feed:
                        FeedView()
                    case .profile:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Tab Bar
                TabBar(selectedTab: $viewModel.selectedTab)
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
