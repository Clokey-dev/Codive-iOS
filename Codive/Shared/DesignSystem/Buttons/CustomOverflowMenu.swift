//
//  CustomOverflowMenu.swift
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

    var items: [MenuItem] {
        switch self {
        case .coordination:
            return [
                .init(icon: .system(name: "pencil"), text: "코디 수정"),
                .init(icon: .system(name: "plus"), text: "룩북에 추가"),
                .init(icon: .asset(name: "ic_share"), text: "코디 공유")
            ]
        case .lookbook:
            return [
                .init(icon: .system(name: "plus.circle.fill"), text: "룩북 만들기"),
                .init(icon: .system(name: "trash"), text: "삭제하기")
            ]
        case .closet:
            return [
                .init(icon: .asset(name: "ic_edit"), text: "수정하기"),
                .init(icon: .system(name: "trash"), text: "삭제하기")
            ]
        case .feed:
            return [
                .init(icon: .system(name: "plus.circle.fill"), text: "코디 추가하기"),
                .init(icon: .asset(name: "ic_edit"), text: "편집하기")
            ]
        case .report:
            return [
                .init(icon: .system(name: "exclamationmark.circle"), text: "신고하기"),
                .init(icon: .asset(name: "ic_block"), text: "차단하기")
            ]
        }
    }
}

enum Icon {
    case system(name: String)
    case asset(name: String)
}

struct MenuItem {
    let icon: Icon
    let text: String
}
struct CustomOverflowMenu: View {
    let menuType: MenuType
    let menuActions: [() -> Void]
    
    @State private var isExpanded = false
    
    init(menuType: MenuType, menuActions: [() -> Void]) {
        self.menuType = menuType
        self.menuActions = menuActions
        
        assert(
            menuType.items.count == menuActions.count,
            "\(menuType) 메뉴의 항목 개수와 연결된 액션 개수가 일치해야 합니다."
        )
    }
    
    private var menuItems: [MenuItem] {
        menuType.items
    }
    
    var body: some View {
        Button(action: toggleMenu) {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .font(.title2)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding()
        }
        .overlay(alignment: .topTrailing) {
            if isExpanded {
                expandedMenu
            }
        }
        .animation(.spring(), value: isExpanded)
        .zIndex(1)
    }
}

// MARK: - Subviews
private extension CustomOverflowMenu {
    var expandedMenu: some View {
        ZStack(alignment: .topTrailing) {
            
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(perform: closeMenu)
            
            VStack(spacing: 0) {
                ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                    Button(
                        action: {
                            performAction(at: index)
                        },
                        label: {
                            menuItemView(item)
                        }
                    )

                    if index < menuItems.count - 1 {
                        Divider()
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 2)
            .fixedSize(horizontal: true, vertical: false)
            .offset(x: -20, y: 50)
            .transition(.scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .zIndex(10)
    }
    
    func menuItemView(_ item: MenuItem) -> some View {
        HStack(spacing: 8) {
            Group {
                switch item.icon {
                case .system(let name):
                    Image(systemName: name)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 20, height: 20)

                case .asset(let name):
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .padding(1)
                }
            }
            .foregroundStyle(Color.Codive.main1)

            Text(item.text)
                .foregroundStyle(Color.Codive.grayscale1)
        }
        .font(.codive_body2_medium)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension CustomOverflowMenu {
    func toggleMenu() {
        withAnimation { isExpanded.toggle() }
    }
    
    func closeMenu() {
        withAnimation { isExpanded = false }
    }
    
    func performAction(at index: Int) {
        guard index < menuActions.count else { return }
        menuActions[index]()
        closeMenu()
    }
}

#Preview {
    CustomOverflowMenu(
        menuType: .coordination,
        menuActions: [
            { print("코디 수정 tapped") },
            { print("룩북에 추가 tapped") },
            { print("코디 공유 tapped") }
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
