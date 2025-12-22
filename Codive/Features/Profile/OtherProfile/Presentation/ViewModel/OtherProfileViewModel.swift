//
//  OtherProfileViewModel.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

class OtherProfileViewModel: ObservableObject {
    // MARK: - Mock Data
    @Published var username: String = "ham_dog"
    @Published var displayName: String = "햄스터강아지"
    @Published var introText: String = "햄스터가 되고 싶은 강아지입니다"
    @Published var followerCount: Int = 22
    @Published var followingCount: Int = 20
    
    // MARK: - State
    @Published var isFollowing: Bool = false
    @Published var month: Date = Date()
    @Published var selectedDate: Date? = Date()
    
    // MARK: - Actions
    func onBackTapped() {
        print("Back tapped")
    }
    
    func onMoreTapped() {
        print("More tapped")
    }
    
    func onFollowerTapped() {
        print("Follower tapped")
    }
    
    func onFollowingTapped() {
        print("Following tapped")
    }
    
    func onFollowButtonTapped() {
        isFollowing.toggle()
        print("Follow button tapped. isFollowing: \(isFollowing)")
    }
    
    func onMoreFavoriteCodiTapped() {
        print("More favorite codi tapped")
    }
}
