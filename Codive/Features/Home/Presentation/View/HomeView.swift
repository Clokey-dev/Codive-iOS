//
//  HomeView.swift
//  Codive
//
//  Created by 한금준 on 10/12/25.
//

import SwiftUI

struct HomeView: View {
    @State private var hasCodi: Bool = true
    @State private var selectedIndex: Int? = 0
    @State private var showClothSelector: Bool = false
    
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
            
            ZStack {
                ScrollView {
                    VStack {
                        WeatherCardView()
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        if hasCodi {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("오늘의 코디 (08.18)")
                                        .font(Font.codive_title1)
                                        .foregroundStyle(Color.Codive.grayscale1)
                                        .padding(.horizontal, 20)
                                    
                                    Spacer()
                                    
                                    CustomOverflowMenu(
                                        menuType: .coordination,
                                        menuActions: [
                                            { print("코디 수정 tapped") },
                                            { print("룩북에 추가 tapped") },
                                            { print("코디 공유 tapped") }
                                        ]
                                    )
                                }
                                
                                ZStack(alignment: .bottomLeading) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.Codive.grayscale7)
                                        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.Codive.grayscale5, lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                                        .padding(.horizontal, 20)
                                    
                                    Button(
                                        action: {
                                            withAnimation(.spring()) {
                                                showClothSelector.toggle()
                                            }
                                        },
                                        label: {
                                            Image("ic_tag")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 28, height: 28)
                                        }
                                    )
                                    .padding(.leading, 16)
                                    .padding()
                                }
                                if showClothSelector {
                                    HStack(spacing: 12) {
                                        ForEach(0..<4, id: \.self) { index in
                                            SelectableClothItemView(
                                                imageName: index == 3 ? nil : "cardigan",
                                                isSelected: Binding(
                                                    get: { selectedIndex == index },
                                                    set: { newValue in
                                                        if newValue { selectedIndex = index }
                                                    }
                                                )
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                
                                CustomBanner(text: "오늘 이 코디를 기억하고 싶다면?") {
                                    print("Icon tapped!")
                                }
                                .padding()
                            }
                        } else {
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
                                CustomButton(text: "코디보드", widthType: .half) {
                                    print("코디보드 tapped")
                                }
                                
                                CustomButton(text: "이 코디로 결정하기", widthType: .half) {
                                    print("이 코디 결정 tapped")
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
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
