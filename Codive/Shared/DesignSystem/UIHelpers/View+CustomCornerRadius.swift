//
//  View+CornerRadius.swift
//  Codive
//
//  Created by 황상환 on 2025/12/01.
//

import SwiftUI

extension View {
    func customCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
