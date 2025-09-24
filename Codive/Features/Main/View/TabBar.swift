//
//  TabBar.swift
//  Codive
//
//  Created by 황상환 on 9/22/25.
//

import SwiftUI

struct TabBar: View {
    
    // MARK: - Properties
    @Binding var selectedTab: TabBarType
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            // MARK: - Home Tab
            TabBarItem(
                icon: TabBarType.home.iconName,
                title: TabBarType.home.title,
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            .frame(maxWidth: .infinity)
            
            // MARK: - Closet Tab
            TabBarItem(
                icon: TabBarType.closet.iconName,
                title: TabBarType.closet.title,
                isSelected: selectedTab == .closet
            ) {
                selectedTab = .closet
            }
            .frame(maxWidth: .infinity)
            
            // MARK: - Add Tab
            TabBarItem(
                icon: TabBarType.add.iconName,
                title: TabBarType.add.title,
                isSelected: selectedTab == .add
            ) {
                selectedTab = .add
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, -12)
            
            // MARK: - Feed Tab
            TabBarItem(
                icon: TabBarType.feed.iconName,
                title: TabBarType.feed.title,
                isSelected: selectedTab == .feed
            ) {
                selectedTab = .feed
            }
            .frame(maxWidth: .infinity)
            
            // MARK: - Profile Tab
            TabBarItem(
                icon: TabBarType.profile.iconName,
                title: TabBarType.profile.title,
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .background(Color.white)
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -1)
        )    }
}
