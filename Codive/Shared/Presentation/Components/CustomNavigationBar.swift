//
//  CustomNavigationBar.swift
//  Codive
//
//  Created by 황상환 on 10/8/25.
//

import SwiftUI

enum NavigationBarRightButton {
    case none
    case text(title: String, isEnabled: Bool, action: () -> Void)
    case icon(systemName: String, isEnabled: Bool, action: () -> Void)
    case menu(systemName: String, isEnabled: Bool, action: () -> Void)
}

struct CustomNavigationBar: View {
    var title: String
    var onBack: () -> Void
    var rightButton: NavigationBarRightButton = .none
    
    var body: some View {
        HStack(spacing: 0) {
            // 왼쪽 뒤로가기 버튼
            Button(action: onBack) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.Codive.grayscale3)
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            // 가운데 타이틀
            Text(title)
                .font(Font.codive_title1)
                .foregroundColor(Color.Codive.grayscale1)
            
            Spacer()
            
            // 오른쪽 버튼
            rightButtonView
                .frame(width: 44, height: 44)
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
        .background(Color.white)
    }
    
    @ViewBuilder
    private var rightButtonView: some View {
        switch rightButton {
        case .none:
            Color.clear
            
        case .text(let title, let isEnabled, let action):
            Button(action: action) {
                Text(title)
                    .font(Font.codive_body2_medium)
                    .foregroundColor(isEnabled ? Color.Codive.point1 : Color.Codive.grayscale5)
            }
            .disabled(!isEnabled)
            
        case .icon(let systemName, let isEnabled, let action):
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isEnabled ? Color.Codive.grayscale3 : Color.Codive.grayscale5)
            }
            .disabled(!isEnabled)
            
        case .menu(let systemName, let isEnabled, let action):
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isEnabled ? Color.Codive.grayscale3 : Color.Codive.grayscale5)
            }
            .disabled(!isEnabled)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        // 1. 버튼 없는 기본 네비게이션
        CustomNavigationBar(
            title: "옷 추가",
            onBack: { print("뒤로가기") }
        )
        
        Divider()
        
        // 2. 오른쪽에 메뉴 버튼 (활성)
        CustomNavigationBar(
            title: "옷 상세",
            onBack: { print("뒤로가기") },
            rightButton: .menu(
                systemName: "ellipsis",
                isEnabled: true,
                action: { print("메뉴 버튼") }
            )
        )
        
        Divider()
        
        // 3. 오른쪽에 텍스트 버튼 (비활성)
        CustomNavigationBar(
            title: "태그하기",
            onBack: { print("뒤로가기") },
            rightButton: .text(
                title: "완료",
                isEnabled: false,
                action: { print("완료 버튼") }
            )
        )
        
        Divider()
        
        // 4. 오른쪽에 텍스트 버튼 (활성)
        CustomNavigationBar(
            title: "옷 수정",
            onBack: { print("뒤로가기") },
            rightButton: .text(
                title: "완료",
                isEnabled: true,
                action: { print("완료 버튼") }
            )
        )
        
        Divider()
        
        // 5. 오른쪽에 텍스트 버튼 (활성 - 삭제)
        CustomNavigationBar(
            title: "옷장 편집",
            onBack: { print("뒤로가기") },
            rightButton: .text(
                title: "삭제",
                isEnabled: true,
                action: { print("삭제 버튼") }
            )
        )
        
        Spacer()
    }
}
