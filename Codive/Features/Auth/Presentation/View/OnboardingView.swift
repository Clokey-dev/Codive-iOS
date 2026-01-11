//
//  OnboardingView.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI

// MARK: - Identifiable URL Wrapper
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Onboarding Data Model
struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

// MARK: - Main Onboarding View
struct OnboardingView: View {
    @State private var currentPage = 0

    let onKakaoLogin: () -> Void
    let onAppleLogin: () -> Void
    let isLoading: Bool
    let errorMessage: String?
    let onErrorDismiss: () -> Void

    // 온보딩 데이터
    private static let pages = [
        OnboardingPage(
            imageName: "onboarding_1",
            title: "오늘의 추천 코디",
            description: "오늘 날씨에 딱 맞는 내 옷장 속 아이템을 추천받고\n좌우로 넘기며 코디를 손쉽게 매치해보세요!"
        ),
        OnboardingPage(
            imageName: "onboarding_2",
            title: "똑똑한 옷장 관리",
            description: "등록한 옷을 폴더로 정리해 관리하고\n착용 기록을 기반으로 리포트를 받아보세요!"
        ),
        OnboardingPage(
            imageName: "onboarding_3",
            title: "나의 옷장에서 시작되는 피드",
            description: "등록한 옷으로 입은 코디와 스타일을 공유하고\n다른 사람들의 패션 아이디어로 영감을 얻어보세요!"
        ),
        OnboardingPage(
            imageName: "onboarding_4",
            title: "나를 담은 스타일 프로필",
            description: "마음에 든 코디를 모아 나만의 취향을 표현하고\n이번 달의 기록을 한눈에 확인해 보세요!"
        )
    ]

    var body: some View {
        ZStack {
            // 배경색
            Color.Codive.main5
                .ignoresSafeArea()

            // 배경 이미지
            TabView(selection: $currentPage) {
                ForEach(0..<Self.pages.count, id: \.self) { index in
                    Image(Self.pages[index].imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 70)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .offset(y: -100)

            // 흰색 카드
            VStack {
                Spacer()

                VStack{
                    // 온보딩 멘트 슬라이드
                    TabView(selection: $currentPage) {
                        ForEach(0..<Self.pages.count, id: \.self) { index in
                            VStack(spacing: 5) {
                                Text(Self.pages[index].title)
                                    .font(.codive_title2)
                                    .foregroundColor(Color.Codive.point1)

                                Text(Self.pages[index].description)
                                    .font(.codive_body1_regular)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black.opacity(0.8))
                                    .lineSpacing(3)
                            }
                            .padding(.horizontal, 30)
                            .tag(index)
                        }
                    }
                    .frame(height: 110)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                    // 인디케이터
                    HStack(spacing: 8) {
                        ForEach(0..<Self.pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.Codive.point1 : Color.gray.opacity(0.3))
                                .frame(width: 5, height: 5)
                        }
                    }
                    .padding(.bottom, 15)

                    // 로그인 버튼들
                    VStack(spacing: 12) {
                        // 카카오 로그인
                        Button(action: onKakaoLogin) {
                            HStack(spacing: 8) {
                                Image(systemName: "message.fill")
                                    .foregroundColor(.black.opacity(0.8))
                                Text("카카오톡으로 시작하기")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 254/255, green: 229/255, blue: 0/255))
                            .cornerRadius(12)
                        }

                        // 애플 로그인 
                        Button(action: onAppleLogin) {
                            HStack(spacing: 8) {
                                Image(systemName: "applelogo")
                                    .foregroundColor(.white)
                                Text("애플로 시작하기")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.black)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
            }
            .ignoresSafeArea(edges: .bottom)

            // 로딩 오버레이
            if isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
            }
        }
        .alert("로그인 오류", isPresented: Binding<Bool>(
            get: { errorMessage != nil },
            set: { _ in onErrorDismiss() }
        )) {
            Button("확인", action: onErrorDismiss)
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

// MARK: - OnboardingContainerView (ViewModel 연결)
struct OnboardingContainerView: View {
    @StateObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingView(
            onKakaoLogin: {
                Task {
                    await viewModel.kakaoLoginButtonTapped()
                }
            },
            onAppleLogin: {
                Task {
                    await viewModel.appleLoginButtonTapped()
                }
            },
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            onErrorDismiss: viewModel.clearError
        )
        .sheet(item: $viewModel.identifiableLoginURL) { item in
            SafariView(url: item.url)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(
        onKakaoLogin: { },
        onAppleLogin: { },
        isLoading: false,
        errorMessage: nil,
        onErrorDismiss: { }
    )
}
