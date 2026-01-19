//
//  SplashView.swift
//  Codive
//
//  Created by 황상환 on 12/27/25.
//

import SwiftUI

// MARK: - SplashView (순수 UI)

struct SplashView: View {

    let displayedText: String
    let fullText: String = "Codive"
    let cursorWidth: CGFloat = 2

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ZStack(alignment: .leading) {
                // 전체 텍스트 (숨김, 레이아웃 기준용)
                HStack(alignment: .center, spacing: 2) {
                    Text(fullText)
                        .font(.codive_splash)

                    Rectangle()
                        .frame(width: cursorWidth, height: 50)
                }
                .opacity(0)

                // 타이핑 애니메이션 텍스트
                HStack(alignment: .center, spacing: 2) {
                    Text(displayedText)
                        .font(.codive_splash)
                        .foregroundColor(Color.Codive.main0)

                    Rectangle()
                        .fill(Color.Codive.main0)
                        .frame(width: cursorWidth, height: 50)
                }
            }
        }
    }
}

// MARK: - SplashContainerView

struct SplashContainerView: View {

    @StateObject private var viewModel: SplashViewModel

    init(appRouter: AppRouter) {
        _viewModel = StateObject(wrappedValue: SplashViewModel(appRouter: appRouter))
    }

    var body: some View {
        SplashView(displayedText: viewModel.displayedText)
            .task {
                await viewModel.startAnimation()
            }
    }
}

// MARK: - Preview

#Preview {
    SplashView(displayedText: "Codi")
}
