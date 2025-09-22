//
//  TabBarItem.swift
//  Codive
//
//  Created by 황상환 on 9/22/25.
//

import SwiftUI

struct TabBarItem: View {
    
    // MARK: - Properties
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // icon
                Image(isSelected ? "\(icon)_selected" : "\(icon)_unselected")
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
                
                // Title
                Text(title)
                    .font(.codive_body4_regular)
                    .foregroundColor(isSelected ? Color.Codive.main0 : Color.Codive.grayscale4)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        // Selected state
        TabBarItem(
            icon: "home",
            title: "홈",
            isSelected: true
        ) {}
        
        // Unselected state
        TabBarItem(
            icon: "home",
            title: "홈",
            isSelected: false
        ) {}
    }
    .padding()
}
