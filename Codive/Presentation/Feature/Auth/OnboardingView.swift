//
//  OnboardingView.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 메인 타이틀
            Text(TextLiteral.Auth.Onboarding.mainTitle)
                .font(.clokey_title1)
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
                // Kakao Login Button
                Button(action: {
                    // TODO: 카카오 로그인 액션 구현
                }) {
                    Image("kakao_login")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                // Apple Login Button
                Button(action: {
                    // TODO: 애플 로그인 액션 구현
                }) {
                    Image("apple_login")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingView()
}
