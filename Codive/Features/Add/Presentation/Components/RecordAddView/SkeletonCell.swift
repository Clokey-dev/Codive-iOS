//
//  SkeletonCell.swift
//  Codive
//
//  Created by 황상환 on 11/3/25.
//

import SwiftUI

// MARK: - SkeletonCell
struct SkeletonCell: View {
    
    // MARK: - Properties
    let size: CGSize
    @State private var isAnimating = false
    
    // MARK: - Body
    var body: some View {
        Rectangle()
            .fill(Color.Codive.grayscale6)
            .frame(width: size.width, height: size.height)
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.Codive.grayscale6.opacity(0.3),
                                Color.white.opacity(0.5),
                                Color.Codive.grayscale6.opacity(0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? size.width * 2 : -size.width * 2)
            )
            .clipShape(Rectangle())
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
