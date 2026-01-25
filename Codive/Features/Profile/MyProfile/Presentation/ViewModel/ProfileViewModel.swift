//
//  ProfileViewModel.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Profile Data
    @Published var userId: Int = 0
    @Published var username: String = ""
    @Published var displayName: String = ""
    @Published var introText: String = ""
    @Published var followerCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var profileImageUrl: String?

    // MARK: - State
    @Published var month: Date = Date()                // 현재 표시 월
    @Published var selectedDate: Date? = Date()        // 선택된 날짜
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let navigationRouter: NavigationRouter
    private let profileAPIService: ProfileAPIServiceProtocol

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, profileAPIService: ProfileAPIServiceProtocol = ProfileAPIService()) {
        self.navigationRouter = navigationRouter
        self.profileAPIService = profileAPIService
    }
    
    // MARK: - Loading
    func loadMyProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            let profileInfo = try await profileAPIService.fetchMyProfile()
            self.userId = profileInfo.userId
            self.username = profileInfo.nickname
            self.displayName = profileInfo.displayName
            self.introText = profileInfo.introduction ?? ""
            self.followerCount = profileInfo.followerCount
            self.followingCount = profileInfo.followingCount
            self.profileImageUrl = profileInfo.profileImageUrl
        } catch {
            self.errorMessage = error.localizedDescription
            print("프로필 로드 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Actions
    func onEditProfileTapped() {
        navigationRouter.navigate(to: .profileSetting)
    }

    func onSettingsTapped() {
        navigationRouter.navigate(to: .settings)
    }

    func onFollowerTapped() {
        navigationRouter.navigate(to: .followList(mode: .followers, memberId: userId))
    }

    func onFollowingTapped() {
        navigationRouter.navigate(to: .followList(mode: .followings, memberId: userId))
    }

    func onMoreFavoriteCodiTapped() {
        navigationRouter.navigate(to: .favoriteCodiList(showHeart: true))
    }
}
