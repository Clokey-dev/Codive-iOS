//
//  MainTabView.swift
//  Codive
//
//  Created by 황상환 on 9/22/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabBarType = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 메인 컨텐츠 영역
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .closet:
                    ClosetView()
                case .add:
                    AddView()
                case .feed:
                    FeedView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 커스텀 탭바
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
