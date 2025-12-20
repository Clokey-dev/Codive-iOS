//
//  CustomNavigationBar.swift
//  Codive
//
//  Created by 황상환 on 10/8/25.
//

import SwiftUI

// MARK: - NavigationBarRightButton
enum NavigationBarRightButton {
    case none
    case text(title: String, isEnabled: Bool, action: () -> Void)
    case icon(imageName: String, isSystemIcon: Bool = true, isEnabled: Bool, action: () -> Void)
    case menu(imageName: String, isSystemIcon: Bool = true, isEnabled: Bool, action: () -> Void)
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
                    .foregroundStyle(Color.Codive.grayscale3)
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            // 가운데 타이틀
            Text(title)
                .font(Font.codive_title1)
                .foregroundStyle(Color.Codive.grayscale1)
            
            Spacer()
            
            // 오른쪽 버튼 영역
            rightButtonView
                .frame(width: 44, height: 44)
                .padding(.trailing, 10)
        }
        .frame(height: 56)
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
                    .foregroundStyle(isEnabled ? Color.Codive.point1 : Color.Codive.grayscale5)
            }
            .disabled(!isEnabled)
            
        case .icon(let imageName, let isSystemIcon, let isEnabled, let action):
            Button(action: action) {
                renderImage(name: imageName, isSystem: isSystemIcon, isEnabled: isEnabled)
            }
            .disabled(!isEnabled)
            
        case .menu(let imageName, let isSystemIcon, let isEnabled, let action):
            Button(action: action) {
                renderImage(name: imageName, isSystem: isSystemIcon, isEnabled: isEnabled)
            }
            .disabled(!isEnabled)
        }
    }
    
    @ViewBuilder
    private func renderImage(name: String, isSystem: Bool, isEnabled: Bool) -> some View {
        if isSystem {
            Image(systemName: name)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(isEnabled ? Color.Codive.grayscale3 : Color.Codive.grayscale5)
        } else {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(isEnabled ? Color.Codive.grayscale3 : Color.Codive.grayscale5)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        CustomNavigationBar(title: "테스트") { print("Back") }
        Divider()
        // 에셋 "more" 버튼 테스트
        CustomNavigationBar(
            title: "에셋 아이콘",
            onBack: { },
            rightButton: .menu(imageName: "more", isSystemIcon: false, isEnabled: true) {
                print("More tapped")
            }
        )
        Divider()
        CustomNavigationBar(
            title: "완료 버튼",
            onBack: { },
            rightButton: .text(title: "완료", isEnabled: true) { }
        )
        Spacer()
    }
}
