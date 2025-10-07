//
//  SwiftUIView.swift
//  Codive
//
//  Created by 한태빈 on 10/7/25.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = 24
    var corners: UIRectCorner = [.topLeft, .topRight]

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    SwiftUIView()
}
