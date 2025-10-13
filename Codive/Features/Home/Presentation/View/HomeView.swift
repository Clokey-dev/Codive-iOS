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
                        .padding(EdgeInsets(top: 24, leading: 20, bottom: 16, trailing: 20))
                    
                    HStack(spacing: 8) {
                        CodiButton(iconName: "plus", title: "카테고리 편집") { }
                        CodiButton(iconName: "shuffle", title: "랜덤 코디") { }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 16)
                    
                    CodiClothView(title: "상의")
                        .padding(.horizontal, 20)
                    CodiClothView(title: "바지")
                        .padding(.horizontal, 20)
                    CodiClothView(title: "신발")
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    HStack(spacing: 16) {
                        CustomButton(text: "코디보드", widthType: .dynamic) {
                            print("코디보드 tapped")
                        }
                        
                        CustomButton(text: "이 코디로 결정하기", widthType: .dynamic) {
                            print("이 코디 결정 tapped")
                        }
                    }
                }
            }
        }
        .background(Color.white)
    }
}

#Preview {
    HomeView()
}
