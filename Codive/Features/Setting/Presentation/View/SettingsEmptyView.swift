//
//  SettingsEmptyView.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//

import SwiftUI

struct SettingsEmptyView: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Color("main2"))
            Text(title).font(.codive_title2).foregroundStyle(Color("Grayscale1"))
            Text(message).font(.codive_body2_regular).foregroundStyle(Color("Grayscale3"))
            CustomButton(text: actionTitle, widthType: .fixed, action: action)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 20)
    }
}
