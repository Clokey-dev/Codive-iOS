//
//  LoadingView.swift
//  Codive
//
//  Created by 황상환 on 11/3/25.
//

import SwiftUI

enum LoadingBackgroundStyle {
    case dimmed   // 검정 반투명 배경
    case white    // 흰색 배경
}

struct LoadingView: View {

    private let backgroundStyle: LoadingBackgroundStyle

    init(backgroundStyle: LoadingBackgroundStyle = .dimmed) {
        self.backgroundStyle = backgroundStyle
    }

    var body: some View {
        ZStack {
            backgroundView

            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: Color.Codive.point2)
                )
                .scaleEffect(1.5)
        }
        .ignoresSafeArea()
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        switch backgroundStyle {
        case .dimmed:
            Color.black.opacity(0.3)
        case .white:
            Color.white
        }
    }
}
