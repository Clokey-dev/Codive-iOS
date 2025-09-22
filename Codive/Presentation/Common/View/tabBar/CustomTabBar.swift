//
//  CustomTabBar.swift
//  Codive
//
//  Created by 황상환 on 9/22/25.
//

import SwiftUI

struct PlusButton: View {
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 42, height: 42)
                
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
    
    private var backgroundColor: Color {
        if isPressed {
            return isSelected ? Color.Codive.main6 : Color.Codive.main0
        } else {
            return isSelected ? Color.Codive.main0 : Color.Codive.main6
        }
    }
    
    private var iconColor: Color {
        if isPressed {
            return isSelected ? Color.Codive.main0 : Color.Codive.main6
        } else {
            return isSelected ? Color.Codive.main6 : Color.Codive.main0
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabBarType
    
    var body: some View {
        HStack(spacing: 0) {
            // home 탭
            TabBarItem(
                icon: TabBarType.home.iconName,
                title: TabBarType.home.title,
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            .frame(maxWidth: .infinity)
            
            // Closet 탭
            TabBarItem(
                icon: TabBarType.closet.iconName,
                title: TabBarType.closet.title,
                isSelected: selectedTab == .closet
            ) {
                selectedTab = .closet
            }
            .frame(maxWidth: .infinity)
            
            // Add 탭
            PlusButton(
                isSelected: selectedTab == .add
            ) {
                selectedTab = .add
            }
            .frame(maxWidth: .infinity)
            .shadow(color: .clear, radius: 0)
            .buttonStyle(PlainButtonStyle())
            
            // feed 탭
            TabBarItem(
                icon: TabBarType.feed.iconName,
                title: TabBarType.feed.title,
                isSelected: selectedTab == .feed
            ) {
                selectedTab = .feed
            }
            .frame(maxWidth: .infinity)
            
            // profile 탭
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
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -1)
    }
}
