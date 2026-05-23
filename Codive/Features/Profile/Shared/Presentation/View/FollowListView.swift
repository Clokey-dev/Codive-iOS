//
//  FollowListView.swift
//  Codive
//
//  Created by 한태빈 on 1/13/26.
//

import SwiftUI

struct FollowListView: View {
    @ObservedObject private var navigationRouter: NavigationRouter
    @ObservedObject private var viewModel: FollowListViewModel

    init(viewModel: FollowListViewModel, navigationRouter: NavigationRouter) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._navigationRouter = ObservedObject(wrappedValue: navigationRouter)
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: viewModel.mode.title,
                onBack: { navigationRouter.navigateBack() },
                rightButton: .none
            )

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let errorMessage = viewModel.errorMessage {
                Spacer()
                Text(errorMessage)
                    .font(.codive_body2_regular)
                    .foregroundStyle(Color.Codive.grayscale4)
                    .multilineTextAlignment(.center)
                Spacer()
            } else if viewModel.items.isEmpty {
                Spacer()
                Text(viewModel.mode == .followers
                     ? "아직 팔로워가 없어요"
                     : "아직 팔로잉이 없어요")
                    .font(.codive_body2_regular)
                    .foregroundStyle(Color.Codive.grayscale4)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.items) { item in
                            CustomUserRow(
                                user: item.user,
                                buttonTitle: item.buttonTitle,
                                buttonStyle: item.buttonStyle
                            ) {
                                viewModel.onTapButton(userId: item.user.userId)
                            }
                            .padding(.top, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.onTapProfile(userId: item.user.userId)
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .enableSwipeBack()
        .task {
            await viewModel.load()
        }
    }
}
