//
//  SettingViewFactory.swift
//  Codive
//
//  Created by 한태빈 on 11/14/25.
//
import SwiftUI

final class SettingViewFactory {

    private unowned let container: SettingDIContainer

    init(settingDIContainer: SettingDIContainer) {
        self.container = settingDIContainer
    }

    @MainActor
    func makeSettingView() -> SettingView {
        container.makeSettingView()
    }

    @MainActor
    func makeSettingLikedView() -> SettingLikedView {
        container.makeSettingLikedView()
    }

    @MainActor
    func makeSettingCommentView() -> SettingCommentView {
        container.makeSettingCommentView()
    }

    @MainActor
    func makeSettingBlockedView() -> SettingBlockedView {
        container.makeSettingBlockedView()
    }
}
