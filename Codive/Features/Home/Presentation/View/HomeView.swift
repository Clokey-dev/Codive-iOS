//
//  HomeView.swift
//  Codive
//
//  Created by 한금준 on 10/12/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            TopNavigationBar(
                onSearchTap: {
                    print("검색 버튼 클릭")
                },
                onNotificationTap: {
                    print("알림 버튼 클릭")
                }
            )
            
            ScrollView {
                VStack {
                    WeatherCardView()
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    Text("오늘 날씨에 이 코디 어때요?")
                        .font(Font.codive_title1)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                    Spacer()
                }
            }
        }
        .background(Color.white)
    }
}

#Preview {
    HomeView()
}
