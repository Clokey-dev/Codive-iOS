//
//  CustomToggle.swift
//  Codive
//
//  Created by 한금준 on 10/5/25.
//

import SwiftUI

enum MenuType {
    case coordination
    case lookbook
    case closet
    case feed
    case report
}

struct MenuItem {
    let icon: String
    let text: String
}

struct CustomOverflowMenu: View {
    let menuType: MenuType
    let menuActions: [() -> Void]
    
    @State private var isExpanded = false
    
    var menuItems: [MenuItem] {
        switch menuType {
        case .coordination:
            return [
                MenuItem(icon: "pencil", text: "코디 수정"),
                MenuItem(icon: "plus", text: "룩북에 추가"),
                MenuItem(icon: "square.and.arrow.up", text: "코디 공유"),
                MenuItem(icon: "arrow.down.circle", text: "이미지 저장")
            ]
        case .lookbook:
            return [
                MenuItem(icon: "plus", text: "룩북 만들기"),
                MenuItem(icon: "trash", text: "삭제하기")
            ]
        case .closet:
            return [
                MenuItem(icon: "square.and.pencil", text: "수정하기"),
                MenuItem(icon: "trash", text: "삭제하기")
            ]
        case .feed:
            return [
                MenuItem(icon: "plus", text: "코디 추가하기"),
                MenuItem(icon: "square.and.pencil", text: "편집하기")
            ]
        case .report:
            return [
                MenuItem(icon: "exclamationmark.circle", text: "신고하기"),
                MenuItem(icon: "nosign", text: "차단하기")
            ]
        }
    }
    
    var body: some View {
        Button(
            action: {
                withAnimation {
                    isExpanded.toggle()
                }
            },
            label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.title2)
                    .foregroundColor(Color.Codive.grayscale1)
                    .padding()
            }
        )
        .overlay(alignment: .topTrailing) {
            if isExpanded {
                // 전체 화면을 덮는 ZStack
                ZStack(alignment: .topTrailing) {
                    
                    // 1. 전체 화면을 덮고 탭 감지 역할을 하는 투명한 배경
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                isExpanded = false
                            }
                        }
                    
                    // 2. 메뉴 리스트 (VStack)
                    VStack(spacing: 0) {
                        ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                            Button(
                                action: {
                                    if index < menuActions.count {
                                        menuActions[index]()
                                    }
                                    withAnimation {
                                        isExpanded = false
                                    }
                                },
                                label: {
                                    menuItem(icon: item.icon, text: item.text)
                                }
                            )
                            if index < menuItems.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                    
                    .offset(x: -20, y: 50)
                    .frame(width: 129) // 메뉴 너비 고정
                    .zIndex(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .animation(.spring(), value: isExpanded)
        .zIndex(1)
    }
    
    private func menuItem(icon: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color.Codive.main1)
                .frame(width: 24, height: 24)
            Text(text)
                .foregroundColor(Color.Codive.grayscale1)
        }
        
        .font(Font.codive_body2_medium)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// --- Preview 코드 ---

#Preview {
    VStack(spacing: 20) {
        CustomOverflowMenu(
            menuType: .coordination,
            menuActions: [
                { print("코디 수정 tapped") },
                { print("룩북에 추가 tapped") },
                { print("코디 공유 tapped") },
                { print("이미지 저장 tapped") }
            ]
        )
        
        Spacer()
            
        
        CustomOverflowMenu(
            menuType: .lookbook,
            menuActions: [
                { print("룩북 만들기 tapped") },
                { print("삭제하기 tapped") }
            ]
        )
        Spacer()
        CustomOverflowMenu(
            menuType: .closet,
            menuActions: [
                { print("수정하기 tapped") },
                { print("삭제하기 tapped") }
            ]
        )
        Spacer()
        CustomOverflowMenu(
            menuType: .feed,
            menuActions: [
                { print("코디 추가하기 tapped") },
                { print("편집하기 tapped") }
            ]
        )
        Spacer()
        CustomOverflowMenu(
            menuType: .report,
            menuActions: [
                { print("신고하기 tapped") },
                { print("차단하기 tapped") }
            ]
        )
        Spacer()
    }
}
