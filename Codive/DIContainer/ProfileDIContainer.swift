//
//  ProfileDIContainer.swift
//  Codive
//
//  Created by 황상환 on 1/25/26.
//

import Foundation

@MainActor
final class ProfileDIContainer {

    // MARK: - Properties
    let navigationRouter: NavigationRouter

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    // MARK: - API Services
    private lazy var profileAPIService: ProfileAPIServiceProtocol = {
        return ProfileAPIService()
    }()

    private lazy var historyAPIService: HistoryAPIServiceProtocol = {
        return HistoryAPIService()
    }()

    // MARK: - Data Sources
    private lazy var profileDataSource: ProfileDataSourceProtocol = {
        return ProfileDataSource(apiService: profileAPIService)
    }()

    // MARK: - Repositories
    private lazy var profileRepository: ProfileRepository = {
        return ProfileRepositoryImpl(dataSource: profileDataSource)
    }()

    private lazy var historyRepository: HistoryRepository = {
        return HistoryRepositoryImpl(historyAPIService: historyAPIService)
    }()

    private lazy var otherProfileRepository: OtherProfileRepository = {
        return OtherProfileRepositoryImpl(apiService: profileAPIService)
    }()

    // MARK: - UseCases
    func makeFetchMyProfileUseCase() -> FetchMyProfileUseCase {
        return DefaultFetchMyProfileUseCase(repository: profileRepository)
    }

    func makeFetchFollowsUseCase() -> FetchFollowsUseCase {
        return DefaultFetchFollowsUseCase(repository: profileRepository)
    }

    func makeUpdateProfileUseCase() -> UpdateProfileUseCase {
        return DefaultUpdateProfileUseCase(repository: profileRepository)
    }

    func makeFetchMonthlyHistoryUseCase() -> FetchMonthlyHistoryUseCase {
        return FetchMonthlyHistoryUseCase(historyRepository: historyRepository)
    }
    
    func makeFetchFavoriteLookBookUseCase() -> FetchFavoriteLookBookUseCase {
        return FetchFavoriteLookBookUseCase(repository: profileRepository)
    }

    func makeFetchMemberInfoUseCase() -> FetchMemberInfoUseCase {
        return DefaultFetchMemberInfoUseCase(repository: otherProfileRepository)
    }

    func makeToggleFollowUseCase() -> ToggleFollowUseCase {
        return DefaultToggleFollowUseCase(repository: otherProfileRepository)
    }

    func makeToggleBlockUseCase() -> ToggleBlockUseCase {
        return DefaultToggleBlockUseCase(repository: otherProfileRepository)
    }

    // MARK: - ViewModels
    private lazy var profileViewModel: ProfileViewModel = {
        return ProfileViewModel(
            navigationRouter: navigationRouter,
            fetchMyProfileUseCase: makeFetchMyProfileUseCase(),
            fetchMonthlyHistoryUseCase: makeFetchMonthlyHistoryUseCase(),
            fetchFavoriteLookBookUseCase: makeFetchFavoriteLookBookUseCase()
        )
    }()

    func makeProfileViewModel() -> ProfileViewModel {
        return profileViewModel
    }

    func makeFollowListViewModel(mode: FollowListMode, memberId: Int, isMe: Bool) -> FollowListViewModel {
        return FollowListViewModel(
            mode: mode,
            memberId: memberId,
            isMe: isMe,
            navigationRouter: navigationRouter,
            fetchFollowsUseCase: makeFetchFollowsUseCase(),
            toggleFollowUseCase: makeToggleFollowUseCase()
        )
    }

    func makeProfileSettingViewModel() -> ProfileSettingViewModel {
        return ProfileSettingViewModel(
            navigationRouter: navigationRouter,
            updateProfileUseCase: makeUpdateProfileUseCase(),
            profileRepository: profileRepository
        )
    }

    func makeOtherProfileViewModel(memberId: Int) -> OtherProfileViewModel {
        return OtherProfileViewModel(
            memberId: memberId,
            navigationRouter: navigationRouter,
            fetchMemberInfoUseCase: makeFetchMemberInfoUseCase(),
            toggleFollowUseCase: makeToggleFollowUseCase(),
            fetchMonthlyHistoryUseCase: makeFetchMonthlyHistoryUseCase(),
            toggleBlockUseCase: makeToggleBlockUseCase(),
            fetchMyFavoriteLookBookUseCase: makeFetchMyFavoriteLookBookUseCase()
        )
    }
    
    func makeFavoriteCodiViewModel() -> FavoriteCodiViewModel {
        return FavoriteCodiViewModel(
            navigationRouter: navigationRouter,
            fetchFavoriteLookBookUseCase: makeFetchFavoriteLookBookUseCase()
        )
    }

    // MARK: - Views
    func makeProfileView() -> ProfileView {
        return ProfileView(viewModel: makeProfileViewModel(), navigationRouter: navigationRouter)
    }

    func makeFollowListView(mode: FollowListMode, memberId: Int, isMe: Bool) -> FollowListView {
        return FollowListView(
            viewModel: makeFollowListViewModel(mode: mode, memberId: memberId, isMe: isMe),
            navigationRouter: navigationRouter
        )
    }

    func makeProfileSettingView() -> ProfileSettingView {
        return ProfileSettingView(
            viewModel: makeProfileSettingViewModel(),
            navigationRouter: navigationRouter
        )
    }
    
    func makeFavoriteCodiView(showHeart: Bool, memberId: Int?) -> FavoriteCodiView {
        return FavoriteCodiView(
            showHeart: showHeart,
            memberId: memberId,
            viewModel: makeFavoriteCodiViewModel(),
            navigationRouter: navigationRouter
        )
    }
}
