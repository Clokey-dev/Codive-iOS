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
                case .feed:
                    FeedView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 커스텀 탭바
            CustomTabBar(
                selectedTab: $selectedTab,
                onPlusButtonTapped: handlePlusButtonTap
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func handlePlusButtonTap() {
        // TODO: 플러스 버튼 액션 (모달 띄우기 등)
        print("Plus button tapped - show modal or navigation")
    }
}

// MARK: - Temporary Views (실제 프로젝트에서는 각각의 Feature 폴더에 있을 View들)
private struct HomeView: View {
    var body: some View {
        NavigationView {
            Text("홈 화면")
                .font(.codive_title1)
                .navigationTitle("홈")
        }
    }
}

private struct ClosetView: View {
    var body: some View {
        NavigationView {
            Text("옷장 화면")
                .font(.codive_title1)
                .navigationTitle("옷장")
        }
    }
}

private struct FeedView: View {
    var body: some View {
        NavigationView {
            Text("피드 화면")
                .font(.codive_title1)
                .navigationTitle("피드")
        }
    }
}

private struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("마이페이지 화면")
                .font(.codive_title1)
                .navigationTitle("마이페이지")
        }
    }
}

#Preview {
    MainTabView()
}
