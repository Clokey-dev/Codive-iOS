//
//  SettingViewFactory.swift
//  Codive
//
//  Created by 한태빈 on 11/14/25.
//
import SwiftUI

@MainActor
final class SettingViewFactory {

    // MARK: - Properties
    private weak var settingDIContainer: SettingDIContainer?

    // MARK: - Init
    init(settingDIContainer: SettingDIContainer) {
        self.settingDIContainer = settingDIContainer
    }

    // MARK: - Destination → View 매핑
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {

        case .settings:
            settingDIContainer?.makeSettingView()

        case .settingLikedRecords:
            settingDIContainer?.makeSettingLikedView()

        case .settingMyComments:
            settingDIContainer?.makeSettingCommentView()

        case .settingBlockedUsers:
            settingDIContainer?.makeSettingBlockedView()

        case .settingWithdraw:
            settingDIContainer?.makeWithdrawView()

        default:
            EmptyView()
        }
    }
}
