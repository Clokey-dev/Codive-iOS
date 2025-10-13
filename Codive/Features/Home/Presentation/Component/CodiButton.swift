//
//  CodiButton.swift
//  Codive
//
//  Created by 한금준 on 10/12/25.
//

import SwiftUI

struct CodiButton: View {
    // MARK: - Properties
    let iconName: String 
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.Codive.main1)
                
                Text(title)
                    .font(Font.codive_body2_regular)
                    .foregroundStyle(Color.Codive.grayscale1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .overlay(
                Capsule()
                    .stroke(Color.Codive.main0, lineWidth: 1)
            )
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        CodiButton(iconName: "plus", title: "카테고리 편집") { }
        CodiButton(iconName: "shuffle", title: "랜덤 코디") { }
    }
    .padding()
}
