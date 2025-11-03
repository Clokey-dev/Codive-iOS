//
//  SettingBlockedView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct SettingBlockedView: View {
    @Environment(\.dismiss) private var dismiss
    
    let blockedUsers = Array(repeating: 0, count: 4)

    var body: some View {
        CustomNavigationBar(title: "차단한 계정") {
            print("뒤로가기")
        }
        Spacer()
        ScrollView {
            VStack(spacing: 16) {
                ForEach(blockedUsers.indices, id: \.self) { _ in
                    CustomUserRow(buttonTitle: "차단 해제")
                }
            }
            .padding(.top, 12)
        }

        Spacer()
    }
}

#Preview {
    SettingBlockedView()
}
