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
    @ObservedObject private var homeViewModel: HomeViewModel
    private let appDIContainer: AppDIContainer
    private let addDIContainer: AddDIContainer
    private let homeDIContainer: HomeDIContainer
    private let closetDIContainer: ClosetDIContainer
    private let feedDIContainer: FeedDIContainer
    private let searchDIContainer: SearchDIContainer
    private let notificationDIContainer: NotificationDIContainer
    private let commentDIContainer: CommentDIContainer
    private let lookBookDIContainer: LookBookDIContainer
    private let settingDIContainer: SettingDIContainer
    private let profileDIContainer: ProfileDIContainer
    private let reportDIContainer: ReportDIContainer

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
        self.settingDIContainer = appDIContainer.makeSettingDIContainer()
        self.profileDIContainer = appDIContainer.makeProfileDIContainer()
        self.reportDIContainer = appDIContainer.makeReportDIContainer()

        self._navigationRouter = ObservedObject(wrappedValue: appDIContainer.navigationRouter)
        let viewModel = MainTabViewModel(
            navigationRouter: appDIContainer.navigationRouter,
            notificationUsecase: notificationDIContainer.topNavigationNotificaionUsecase
        )
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.homeViewModel = homeDIContainer.makeHomeViewModel()
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            NavigationStack(path: $navigationRouter.path) {
                // 최상위 ZStack: 여기서 시트를 띄워야 전체(상단바 포함)를 덮습니다.
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        // 1. 상단바
                        if shouldShowTopBar {
                            TopNavigationBar(
                                showSearchButton: showSearchButton,
                                showNotificationButton: showNotificationButton,
                                hasUnreadNotification: viewModel.hasUnreadNotification,
                                onSearchTap: viewModel.handleSearchTap,
                                onNotificationTap: viewModel.handleNotificationTap
                            )
                        }

                        // 2. 메인 콘텐츠 영역
                        Group {
                            switch viewModel.selectedTab {
                            case .home:
                                HomeView(homeDIContainer: homeDIContainer, viewModel: homeViewModel)
                                    .ignoresSafeArea(.all, edges: .bottom)
                            case .closet:
                                ClosetView(closetDIContainer: closetDIContainer)
                            case .add:
                                AddView(addDIContainer: addDIContainer)
                                    .ignoresSafeArea(.all, edges: .bottom)
                            case .feed:
                                FeedView(viewModel: feedDIContainer.makeFeedViewModel())
                            case .profile:
                                profileDIContainer.makeProfileView()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        // 3. 하단 탭바
                        TabBar(selectedTab: $viewModel.selectedTab)
                            .zIndex(shouldShowTabBar ? 1 : 0)
                            .allowsHitTesting(shouldShowTabBar)
                    }
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)

                    // 4. 바텀시트: VStack(상단바+컨텐츠+탭바) 위에 배치하여 전체를 딤 처리
                    if homeViewModel.showLookBookSheet {
                        AddBottomSheet(
                            isPresented: $homeViewModel.showLookBookSheet,
                            entities: homeViewModel.lookBookList,
                            thumbnailProvider: { entity in
                                AsyncImage(url: URL(string: entity.imageUrl)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                            },
                            onTapEntity: { entity in
                                homeViewModel.selectLookBook(entity)
                            }
                        )
                        .zIndex(100) // 가장 높은 숫자로 설정
                        .transition(.move(edge: .bottom))
                    }
                    
                    if homeViewModel.showCompletePopUp {
                        CompletePopUp(
                            isPresented: $homeViewModel.showCompletePopUp,
                            onRecordTapped: homeViewModel.handlePopupRecord,
                            onCloseTapped: homeViewModel.handlePopupClose,
                            selectedClothes: homeViewModel.selectedCodiClothes,
                            singleImageUrl: homeViewModel.capturedImageURL
                        )
                        .id(homeViewModel.capturedImageURL)
                        .zIndex(200)
                    }
                }
                .environmentObject(navigationRouter)
                .onReceive(navigationRouter.$pendingTabSwitch) { tab in
                    if let tab = tab {
                        viewModel.selectedTab = tab
                        navigationRouter.pendingTabSwitch = nil
                    }
                }
            }

            // MARK: - Confirm Loading Overlay
            if homeViewModel.isConfirmLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                }
                .zIndex(400)
            }

            // MARK: - Success Overlay
            if let message = navigationRouter.successMessage {
                CustomSuccessView(message: message)
                    .ignoresSafeArea()
                    .zIndex(100)
                    .transition(.opacity)
            }

            // MARK: - Empty History Modal Overlay
            if viewModel.isEmptyHistoryModalPresented {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.isEmptyHistoryModalPresented = false
                        viewModel.emptyHistoryModalDate = nil
                    }
                    .zIndex(300)

                EmptyHistoryModalView(
                    selectedDate: viewModel.emptyHistoryModalDate,
                    onClose: {
                        viewModel.isEmptyHistoryModalPresented = false
                        viewModel.emptyHistoryModalDate = nil
                    },
                    onAddRecord: {
                        viewModel.isEmptyHistoryModalPresented = false
                        viewModel.emptyHistoryModalDate = nil
                        navigationRouter.navigate(to: .recordAdd)
                    }
                )
                .frame(height: 310, alignment: .center)
                .padding(.horizontal, 55)
                .zIndex(301)
            }
        }
        .onAppear {
            viewModel.loadNotificationExist()
        }
        .environmentObject(viewModel)
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

        // 기본 규칙: Add, Profile 탭에서만 상단바 숨김
        return viewModel.selectedTab != .add && viewModel.selectedTab != .profile
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
        // MARK: - Search
        case .search:
            searchDIContainer.makeSearchView()
        case .searchResult(let query):
            searchDIContainer.makeSearchResultView(initialQuery: query)
        case .recentlySearchResult:
            searchDIContainer.makeRecentlySearchResultView()
        case .notification:
            notificationDIContainer.makeNotificationView()

        // MARK: - Feed
        case .feedDetail(let feedId):
            feedDIContainer.makeFeedDetailView(feedId: feedId)
        case .otherProfile:
            feedDIContainer.feedViewFactory.makeView(for: destination)
        case .comment(let feedId):
            commentDIContainer.makeCommentView(feedId: feedId)

        // MARK: - Home
        case .editCategory:
            homeDIContainer.makeEditCategoryView()
        case .codiBoard:
            homeDIContainer.makeCodiBoardView()

        // MARK: - Profile & Settings
        case .favoriteCodiList(let showHeart):
            profileDIContainer.makeFavoriteCodiView(showHeart: showHeart)
        case .settings:
            settingDIContainer.makeSettingView()
        case .settingLikedRecords:
            settingDIContainer.makeSettingLikedView()
        case .settingMyComments:
            settingDIContainer.makeSettingCommentView()
        case .settingBlockedUsers:
            settingDIContainer.makeSettingBlockedView()
        case .settingWithdraw:
            settingDIContainer.makeWithdrawView()
        case .profileSetting:
            profileDIContainer.makeProfileSettingView()
        case .myProfile:
            profileDIContainer.makeProfileView()
        case .followList(let mode, let memberId, let isMe):
            profileDIContainer.makeFollowListView(mode: mode, memberId: memberId, isMe: isMe)

        // MARK: - Closet
        case .myCloset:
            closetDIContainer.makeMyClosetView()
        case .clothDetail, .clothEdit:
            closetDIContainer.closetViewFactory.makeView(for: destination)

        // MARK: - Add / LookBook / Report
        case .recordAdd, .clothPhotoSelect, .photoEdit, .photoEditForCloth, .recordDetail, .recordEdit, .photoTag, .clothAdd:
            addDIContainer.addViewFactory.makeView(for: destination)
        case .lookbook, .specificLookbook, .addCodi, .addCodiDetail, .addBeforeCodi, .codiDetail, .editCodi:
            lookBookDIContainer.lookBookViewFactory.makeView(for: destination)
        case .report, .reportDetail:
            reportDIContainer.reportViewFactory.makeView(for: destination)

        default:
            EmptyView()
        }
    }
}
