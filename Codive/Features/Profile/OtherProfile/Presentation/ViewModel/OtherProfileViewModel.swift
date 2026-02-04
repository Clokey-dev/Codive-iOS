//
//  OtherProfileViewModel.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

@MainActor
class OtherProfileViewModel: ObservableObject {
    // MARK: - Mock Data
    @Published var displayName: String = "햄스터강아지"
    @Published var introText: String = "햄스터가 되고 싶은 강아지입니다"
    @Published var followerCount: Int = 22
    @Published var followingCount: Int = 20
    
    // MARK: - State
    @Published var isFollowing: Bool = false
    @Published var month: Date = Date()
    @Published var selectedDate: Date? = Date()
    @Published var isBlockMenuPresented: Bool = false
    @Published var monthlyHistories: [String: String] = [:] // "2026-01-21" -> imageUrl
    
    // MARK: - Dependencies
    private let navigationRouter: NavigationRouter
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - Actions
    func onBackTapped() {
        navigationRouter.navigateBack()
    }
    
    func showBlockMenu() {
        isBlockMenuPresented = true
    }
    
    func dismissBlockMenu() {
        isBlockMenuPresented = false
    }
    
    func onBlockTapped() {
        dismissBlockMenu()
        print("Block tapped")
    }
    
    func onFollowerTapped() {
        navigationRouter.navigate(to: .followList(mode: .followers, memberId: 0)) // TODO: 실제 userId로 변경 필요
    }

    func onFollowingTapped() {
        navigationRouter.navigate(to: .followList(mode: .followings, memberId: 0)) // TODO: 실제 userId로 변경 필요
    }
    
    func onFollowButtonTapped() {
        isFollowing.toggle()
        print("Follow button tapped. isFollowing: \(isFollowing)")
    }
    
    func onMoreFavoriteCodiTapped() {
        navigationRouter.navigate(to: .favoriteCodiList(showHeart: false))
    }
}
