//
//  CustomTabBar.swift
//  Codive
//
//  Created by 황상환 on 9/22/25.
//

import SwiftUI

struct PlusButton: View {
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(isPressed ? Color.Codive.main0 : Color.Codive.main6)
                    .frame(width: 42, height: 42)
                
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isPressed ? Color.Codive.main6 : Color.Codive.main0)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabBarType
    let onPlusButtonTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // 첫 번째 탭 (홈)
            TabBarItem(
                icon: TabBarType.home.iconName,
                title: TabBarType.home.title,
                isSelected: selectedTab == .home,
                action: {
                    selectedTab = .home
                }
            )
            .frame(maxWidth: .infinity)
            
            // 두 번째 탭 (옷장)
            TabBarItem(
                icon: TabBarType.closet.iconName,
                title: TabBarType.closet.title,
                isSelected: selectedTab == .closet,
                action: {
                    selectedTab = .closet
                }
            )
            .frame(maxWidth: .infinity)
            
            // 가운데 플러스 버튼
            PlusButton(onTap: onPlusButtonTapped)
                .frame(maxWidth: .infinity)
            
            // 세 번째 탭 (피드)
            TabBarItem(
                icon: TabBarType.feed.iconName,
                title: TabBarType.feed.title,
                isSelected: selectedTab == .feed,
                action: {
                    selectedTab = .feed
                }
            )
            .frame(maxWidth: .infinity)
            
            // 네 번째 탭 (프로필)
            TabBarItem(
                icon: TabBarType.profile.iconName,
                title: TabBarType.profile.title,
                isSelected: selectedTab == .profile,
                action: {
                    selectedTab = .profile
                }
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
    }
}

#Preview {
    VStack {
        Spacer()
        
        CustomTabBar(
            selectedTab: .constant(.home),
            onPlusButtonTapped: {
                print("Plus button tapped!")
            }
        )
    }
    .background(Color.gray.opacity(0.1))
}
