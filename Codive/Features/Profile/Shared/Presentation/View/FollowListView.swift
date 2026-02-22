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

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.items) { item in
                        CustomUserRow(
                            user: item.user,
                            buttonTitle: item.buttonTitle,
                            buttonStyle: viewModel.isMe ? item.buttonStyle : .none
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
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .enableSwipeBack()
        .task {
            await viewModel.load()
        }
    }
}
