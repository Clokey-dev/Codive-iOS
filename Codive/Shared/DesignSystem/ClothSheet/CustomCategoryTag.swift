//
//  CustomCategoryTag.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import SwiftUI

struct CustomCategoryTag: View {
    
    // MARK: - Properties
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(SelectionButtonStyle(isSelected: isSelected))
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 8) {
        CustomCategoryTag(title: "전체", isSelected: true) { }
        CustomCategoryTag(title: "상의", isSelected: false) { }
        CustomCategoryTag(title: "바지", isSelected: false) { }
    }
    .padding(20)
}
