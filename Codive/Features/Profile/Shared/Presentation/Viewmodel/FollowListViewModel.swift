//
//  FollowListViewModel.swift
//  Codive
//
//  Created by 한태빈 on 1/13/26.
//

import Foundation
import SwiftUI

final class FollowListViewModel: ObservableObject {
    @Published private(set) var items: [FollowRowItem] = []
    let mode: FollowListMode

    init(mode: FollowListMode) {
        self.mode = mode
        load()
    }

    func load() {
        // 실제 구현에서는 mode에 따라 API 분기

        if mode == .followers {
            items = [
                .init(user: .init(userId: 1, nickname: "닉네임", handle: "아이디", avatarURL: nil), isFollowing: false),
                .init(user: .init(userId: 2, nickname: "닉네임", handle: "아이디", avatarURL: nil), isFollowing: true)
            ]
        } else {
            items = [
                .init(user: .init(userId: 3, nickname: "닉네임", handle: "아이디", avatarURL: nil), isFollowing: true),
                .init(user: .init(userId: 4, nickname: "닉네임", handle: "아이디", avatarURL: nil), isFollowing: true)
            ]
        }
    }

    func onTapButton(userId: UserID) {
        guard let idx = items.firstIndex(where: { $0.id == userId }) else { return }

        // 공통: 현재 버튼은 follow/following 토글
        // 실제 구현: API 성공 후 반영
        items[idx].isFollowing.toggle()

        // mode가 followings인 경우:
        // "팔로잉" 목록에서 언팔로우하면 리스트에서 제거
        if mode == .followings, items[idx].isFollowing == false {
            items.remove(at: idx)
        }
    }
}

struct FollowRowItem: Identifiable, Hashable {
    let user: SimpleUser
    var isFollowing: Bool

    var id: UserID { user.userId }

    var buttonTitle: String {
        isFollowing ? "팔로잉" : "팔로우"
    }

    var buttonStyle: CustomUserRowButtonStyle {
        isFollowing ? .secondary : .primary
    }
}
