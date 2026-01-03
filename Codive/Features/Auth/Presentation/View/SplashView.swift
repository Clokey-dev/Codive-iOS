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

// MARK: - SplashContainerView (로직 담당)
struct SplashContainerView: View {

    @StateObject private var viewModel: SplashViewModel

    init(appRouter: AppRouter) {
        _viewModel = StateObject(wrappedValue: SplashViewModel(appRouter: appRouter))
    }

    var body: some View {
        SplashView(displayedText: viewModel.displayedText)
            .onAppear {
                viewModel.startAnimation()
            }
    }
}

// MARK: - SplashViewModel (타이핑 애니메이션 로직)
@MainActor
final class SplashViewModel: ObservableObject {

    @Published var displayedText: String = ""

    private let fullText: String = "Codive"
    private let typingSpeed: Double = 0.4
    private var textIndex: Int = 0
    private var timer: Timer?
    private let appRouter: AppRouter

    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            if self.textIndex < self.fullText.count {
                self.textIndex += 1
                let index = self.fullText.index(self.fullText.startIndex, offsetBy: self.textIndex)
                self.displayedText = String(self.fullText[..<index])
            } else {
                timer.invalidate()
                // 애니메이션 종료 후 0.5초 대기 후 다음 화면으로
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.appRouter.finishSplash()
                }
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}

// MARK: - Preview
#Preview {
    SplashView(displayedText: "Codi")
}
