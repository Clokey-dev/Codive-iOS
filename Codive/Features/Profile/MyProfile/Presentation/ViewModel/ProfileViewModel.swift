//
//  ProfileViewModel.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    // MARK: - Mock Data
    @Published var username: String = "kiki01"
    @Published var displayName: String = "일기러버"
    @Published var introText: String = "안녕하세요 일기 러버에요"
    @Published var followerCount: Int = 22
    @Published var followingCount: Int = 20
    
    // MARK: - State
    @Published var month: Date = Date()                // 현재 표시 월
    @Published var selectedDate: Date? = Date()        // 선택된 날짜
    
    // MARK: - Actions
    func onEditProfileTapped() {
        print("Edit profile tapped")
    }
    
    func onSettingsTapped() {
        print("Settings tapped")
    }
    
    func onFollowerTapped() {
        print("Follower tapped")
    }
    
    func onFollowingTapped() {
        print("Following tapped")
    }
    
    func onMoreFavoriteCodiTapped() {
        print("More favorite codi tapped")
    }
}
