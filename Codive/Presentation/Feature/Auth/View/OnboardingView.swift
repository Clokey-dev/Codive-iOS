//
//  OnboardingView.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI

struct OnboardingView: View {
    
    // MARK: - Properties
    @StateObject var viewModel: OnboardingViewModel
    
    // MARK: - Initializer
    init(viewModel: OnboardingViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 메인 타이틀
            Text(TextLiteral.Auth.Onboarding.mainTitle)
                .font(.codive_title1)
                .padding(.top, 75)
                .padding(.horizontal, 20)

            Spacer()

            // 온보딩 이미지
            HStack {
                Spacer()
                Image("onboarding_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 215)
                Spacer()
            }
            
            Spacer()

            // 로그인 버튼
            VStack(spacing: 16) {
                Button(
                    action: {
                        viewModel.loginButtonTapped()
                    },
                    label: {
                        Image("kakao_login")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                )

                Button(
                    action: {
                        // TODO: 애플 로그인 액션 구현
                    },
                    label: {
                        Image("apple_login")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Preview
#Preview {
    let appDIContainer = AppDIContainer()
    let authDIContainer = appDIContainer.makeAuthDIContainer()
    
    return OnboardingView(viewModel: authDIContainer.makeOnboardingViewModel())
}
