//
//  FollowListViewModel.swift
//  Codive
//
//  Created by 한태빈 on 1/13/26.
//

import Foundation
import SwiftUI

@MainActor
final class FollowListViewModel: ObservableObject {
    @Published private(set) var items: [FollowRowItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let mode: FollowListMode
    let isMe: Bool
    private let fetchFollowsUseCase: FetchFollowsUseCase
    private let memberId: Int
    private let navigationRouter: NavigationRouter

    init(
        mode: FollowListMode,
        memberId: Int,
        isMe: Bool,
        navigationRouter: NavigationRouter,
        fetchFollowsUseCase: FetchFollowsUseCase
    ) {
        self.mode = mode
        self.memberId = memberId
        self.isMe = isMe
        self.navigationRouter = navigationRouter
        self.fetchFollowsUseCase = fetchFollowsUseCase
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await fetchFollowsUseCase.execute(
                memberId: memberId,
                isFollowing: mode == .followings,
                lastFollowId: nil,
                size: 20
            )

            self.items = result.followers.map { user in
                FollowRowItem(user: user, isFollowing: true)
            }
        } catch {
            self.errorMessage = error.localizedDescription
            #if DEBUG
            print("[Follow] 팔로우 목록 로드 실패: \(error.localizedDescription)")
            #endif
        }

        isLoading = false
    }

    func onTapProfile(userId: UserID) {
        navigationRouter.navigate(to: .otherProfile(userId: Int(userId) ?? 0))
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
