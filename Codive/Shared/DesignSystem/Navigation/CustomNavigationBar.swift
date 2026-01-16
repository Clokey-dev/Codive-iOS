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
    case overflow(menuType: MenuType, menuActions: [() -> Void])
    case icon(imageName: String, isSystemIcon: Bool = true, isEnabled: Bool, action: () -> Void)
    case menu(imageName: String, isSystemIcon: Bool = true, isEnabled: Bool, action: () -> Void)
}

struct CustomNavigationBar: View {
    @Binding var title: String
    var isEditingMode: Bool = false
    var onBack: () -> Void
    var onBeginEditTitle: (() -> Void)?
    var onConfirmEditTitle: (() -> Void)?
    var onCancelEditTitle: (() -> Void)?
    var rightButton: NavigationBarRightButton = .none
    
    init(
        title: Binding<String>,
        isEditingMode: Bool = false,
        onBack: @escaping () -> Void,
        onBeginEditTitle: (() -> Void)? = nil,
        onConfirmEditTitle: (() -> Void)? = nil,
        onCancelEditTitle: (() -> Void)? = nil,
        rightButton: NavigationBarRightButton = .none
    ) {
        self._title = title
        self.isEditingMode = isEditingMode
        self.onBack = onBack
        self.onBeginEditTitle = onBeginEditTitle
        self.onConfirmEditTitle = onConfirmEditTitle
        self.onCancelEditTitle = onCancelEditTitle
        self.rightButton = rightButton
    }

    init(title: String, onBack: @escaping () -> Void, rightButton: NavigationBarRightButton = .none) {
        self._title = .constant(title)
        self.isEditingMode = false
        self.onBack = onBack
        self.rightButton = rightButton
    }
    
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
            
            if isEditingMode {
                VStack(spacing: 4) {
                    TextField("", text: $title) {
                        onConfirmEditTitle?()
                    }
                    .font(Font.codive_title1)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.Codive.grayscale4)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
            } else {
                Text(title)
                    .font(Font.codive_title1)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .onTapGesture {
                        onBeginEditTitle?()
                    }
            }
            
            Spacer()
            
            // 오른쪽 버튼
            Group {
                if case .overflow = rightButton {
                    rightButtonView
                        .padding(.trailing, 10)
                } else {
                    rightButtonView
                        .frame(width: 44, height: 44)
                        .padding(.trailing, 10)
                }
            }
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
            
        case .overflow(let menuType, let menuActions):
            CustomOverflowMenu(menuType: menuType, menuActions: menuActions)
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
        
        Divider()
        
        // 4. 오른쪽에 텍스트 버튼 (활성)
        CustomNavigationBar(
            title: "옷 수정",
            onBack: { print("뒤로가기") },
            rightButton: .text(
                title: "완료",
                isEnabled: true
            ) {
                print("완료 버튼")
            }
        )
        
        Divider()
        
        // 5. 오른쪽에 텍스트 버튼 (활성 - 삭제)
        CustomNavigationBar(
            title: "옷장 편집",
            onBack: { print("뒤로가기") },
            rightButton: .text(
                title: "삭제",
                isEnabled: true
            ) {
                print("삭제 버튼")
            }
        )
        
        Divider()
        
        CustomNavigationBar(
            title: "데이트 룩",
            onBack: { print("뒤로가기") },
            rightButton: .overflow(
                    menuType: .feed,
                    menuActions: [
                        { print("코디 추가하기 tapped") },
                        { print("편집하기 tapped") }
                    ]
                )
        )
        .zIndex(10)
        
        Spacer()
    }
}
