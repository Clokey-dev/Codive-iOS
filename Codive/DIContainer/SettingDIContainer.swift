//
//  SettingDIContainer.swift
//  Codive
//
//  Created by 한태빈 on 11/14/25.
//

import Foundation
import SwiftUI

@MainActor
final class SettingDIContainer {

    // MARK: - Dependencies
    private let appRouter: AppRouter
    private let navigationRouter: NavigationRouter

    // ViewFactory
    lazy var settingViewFactory = SettingViewFactory(settingDIContainer: self)
    
    // Data / Repository
    private let dataSource: SettingsDataSource
    private let repository: SettingRepository    // ← 프로토콜 타입으로 보관

    // MARK: - Init
    init(appRouter: AppRouter, navigationRouter: NavigationRouter) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter

        // 인메모리 스텁 + 레포지토리 연결
        let dataSource = SettingsDataSource()
        self.dataSource = dataSource
        self.repository = SettingsRepositoryImpl(dataSource: dataSource)
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
            updatePrefsUC: makeUpdateNotificationPrefsUseCase()
        )
    }

    func makeLikedRecordsViewModel() -> LikedRecordsViewModel {
        LikedRecordsViewModel(
            getLikedUC: makeGetLikedRecordsUseCase()
        )
    }

    func makeMyCommentsViewModel() -> MyCommentsViewModel {
        MyCommentsViewModel(
            getCommentsUC: makeGetMyCommentsUseCase()
        )
    }

    func makeBlockedUsersViewModel() -> BlockedUsersViewModel {
        BlockedUsersViewModel(
            getBlocked: makeGetBlockedUsersUseCase(),
            unblock: makeUnblockUserUseCase()
        )
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
}
