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
    private let toggleFollowUseCase: ToggleFollowUseCase
    private let memberId: Int
    private let navigationRouter: NavigationRouter

    init(
        mode: FollowListMode,
        memberId: Int,
        isMe: Bool,
        navigationRouter: NavigationRouter,
        fetchFollowsUseCase: FetchFollowsUseCase,
        toggleFollowUseCase: ToggleFollowUseCase
    ) {
        self.mode = mode
        self.memberId = memberId
        self.isMe = isMe
        self.navigationRouter = navigationRouter
        self.fetchFollowsUseCase = fetchFollowsUseCase
        self.toggleFollowUseCase = toggleFollowUseCase
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

            self.items = result.followers.map { member in
                FollowRowItem(user: member.user, isFollowing: member.isFollowing, isMe: member.isMe)
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
        let targetMemberId = Int(userId) ?? 0

        Task {
            do {
                try await toggleFollowUseCase.execute(memberId: targetMemberId, isPublic: true)
                items[idx].isFollowing.toggle()

                if mode == .followings, items[idx].isFollowing == false {
                    items.remove(at: idx)
                }
                NotificationCenter.default.post(name: .followDidChange, object: nil)
            } catch {
                errorMessage = "팔로우 변경에 실패했습니다."
            }
        }
    }
}

struct FollowRowItem: Identifiable, Hashable {
    let user: SimpleUser
    var isFollowing: Bool
    let isMe: Bool

    var id: UserID { user.userId }

    var buttonTitle: String {
        isFollowing ? "팔로잉" : "팔로우"
    }

    var buttonStyle: CustomUserRowButtonStyle {
        if isMe { return .none }
        return isFollowing ? .secondary : .primary
    }
}
