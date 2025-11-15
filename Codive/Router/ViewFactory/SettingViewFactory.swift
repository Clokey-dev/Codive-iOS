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

    func makeSettingView() -> SettingView {
        container.makeSettingView()
    }

    func makeSettingLikedView() -> SettingLikedView {
        container.makeSettingLikedView()
    }

    func makeSettingCommentView() -> SettingCommentView {
        container.makeSettingCommentView()
    }

    func makeSettingBlockedView() -> SettingBlockedView {
        container.makeSettingBlockedView()
    }
}
