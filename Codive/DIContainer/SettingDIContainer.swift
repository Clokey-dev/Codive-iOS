//
//  SettingDIContainer.swift
//  Codive
//
//  Created by 한태빈 on 11/14/25.
//

import Foundation
import SwiftUI
import CodiveAPI

@MainActor
final class SettingDIContainer {

    // MARK: - Dependencies
    private let appRouter: AppRouter
    private let navigationRouter: NavigationRouter
    private let profileDIContainer: ProfileDIContainer
    private let authDIContainer: AuthDIContainer
    private let apiClient: Client

    // ViewFactory
    lazy var settingViewFactory = SettingViewFactory(settingDIContainer: self)

    // Data / Repository
    private let repository: SettingRepository

    // MARK: - Init
    init(
        appRouter: AppRouter,
        navigationRouter: NavigationRouter,
        profileDIContainer: ProfileDIContainer,
        authDIContainer: AuthDIContainer,
        apiClient: Client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: KeychainTokenProvider())]
        )
    ) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
        self.profileDIContainer = profileDIContainer
        self.authDIContainer = authDIContainer
        self.apiClient = apiClient

        let dataSource = SettingsDataSource(apiClient: apiClient)
        let repo = SettingsRepositoryImpl(dataSource: dataSource)
        self.repository = repo
    }

    // MARK: - UseCases
    func makeGetNotificationPrefsUseCase() -> GetNotificationPrefsUseCase {
        GetNotificationPrefsUseCase(repository: repository)
    }

    func makeUpdateNotificationPrefsUseCase() -> UpdateNotificationPrefsUseCase {
        UpdateNotificationPrefsUseCase(repository: repository)
    }

    func makeGetLikedRecordsUseCase() -> GetLikedRecordsUseCase {
        GetLikedRecordsUseCase(repository: repository)
    }

    func makeGetMyCommentsUseCase() -> GetMyCommentsUseCase {
        GetMyCommentsUseCase(repository: repository)
    }

    func makeGetBlockedUsersUseCase() -> GetBlockedUsersUseCase {
        GetBlockedUsersUseCase(repository: repository)
    }

    func makeUnblockUserUseCase() -> UnblockUserUseCase {
        UnblockUserUseCase(repository: repository)
    }

    func makeGetWithdrawNoticesUseCase() -> GetWithdrawNoticesUseCase {
        GetWithdrawNoticesUseCase(repository: repository)
    }

    // MARK: - ViewModels
    func makeSettingViewModel() -> SettingViewModel {
        SettingViewModel(
            appRouter: appRouter,
            navigationRouter: navigationRouter,
            getPrefsUC: makeGetNotificationPrefsUseCase(),
            updatePrefsUC: makeUpdateNotificationPrefsUseCase(),
            authRepository: authDIContainer.authRepository,
            profileViewModel: profileDIContainer.makeProfileViewModel()
        )
    }

    func makeLikedRecordsViewModel() -> LikedRecordsViewModel {
        LikedRecordsViewModel(
            navigationRouter: navigationRouter,
            getLikedUC: makeGetLikedRecordsUseCase()
        )
    }

    func makeMyCommentsViewModel() -> MyCommentsViewModel {
        MyCommentsViewModel(
            navigationRouter: navigationRouter,
            getCommentsUC: makeGetMyCommentsUseCase()
        )
    }

    func makeBlockedUsersViewModel() -> BlockedUsersViewModel {
        BlockedUsersViewModel(
            navigationRouter: navigationRouter,
            getBlockedUC: makeGetBlockedUsersUseCase(),
            unblockUC: makeUnblockUserUseCase()
        )
    }

    func makeWithdrawViewModel() -> WithdrawViewModel {
        WithdrawViewModel(navigationRouter: navigationRouter, appRouter: appRouter, apiClient: apiClient)
    }

    // MARK: - Views
    func makeSettingView() -> SettingView {
        SettingView(viewModel: self.makeSettingViewModel())
    }

    func makeSettingLikedView() -> SettingLikedView {
        SettingLikedView(vm: self.makeLikedRecordsViewModel())
    }

    func makeSettingCommentView() -> SettingCommentView {
        SettingCommentView(vm: self.makeMyCommentsViewModel())
    }

    func makeSettingBlockedView() -> SettingBlockedView {
        SettingBlockedView(vm: self.makeBlockedUsersViewModel())
    }

    func makeWithdrawView() -> WithdrawView {
        WithdrawView(vm: makeWithdrawViewModel())
    }
}
