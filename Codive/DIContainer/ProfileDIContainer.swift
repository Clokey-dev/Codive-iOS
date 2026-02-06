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

    func makeFetchMemberInfoUseCase() -> FetchMemberInfoUseCase {
        return DefaultFetchMemberInfoUseCase(repository: otherProfileRepository)
    }

    func makeToggleFollowUseCase() -> ToggleFollowUseCase {
        return DefaultToggleFollowUseCase(repository: otherProfileRepository)
    }

    // MARK: - ViewModels
    private lazy var profileViewModel: ProfileViewModel = {
        return ProfileViewModel(
            navigationRouter: navigationRouter,
            fetchMyProfileUseCase: makeFetchMyProfileUseCase(),
            fetchMonthlyHistoryUseCase: makeFetchMonthlyHistoryUseCase()
        )
    }()

    func makeProfileViewModel() -> ProfileViewModel {
        return profileViewModel
    }

    func makeFollowListViewModel(mode: FollowListMode, memberId: Int) -> FollowListViewModel {
        return FollowListViewModel(
            mode: mode,
            memberId: memberId,
            fetchFollowsUseCase: makeFetchFollowsUseCase()
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
            fetchMonthlyHistoryUseCase: makeFetchMonthlyHistoryUseCase()
        )
    }

    // MARK: - Views
    func makeProfileView() -> ProfileView {
        return ProfileView(viewModel: makeProfileViewModel(), navigationRouter: navigationRouter)
    }

    func makeFollowListView(mode: FollowListMode, memberId: Int) -> FollowListView {
        return FollowListView(
            viewModel: makeFollowListViewModel(mode: mode, memberId: memberId),
            navigationRouter: navigationRouter
        )
    }

    func makeProfileSettingView() -> ProfileSettingView {
        return ProfileSettingView(
            viewModel: makeProfileSettingViewModel(),
            navigationRouter: navigationRouter
        )
    }
}
