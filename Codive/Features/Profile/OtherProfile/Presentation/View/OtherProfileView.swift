//
//  OtherProfileView.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

// MARK: - View
struct OtherProfileView: View {
    @ObservedObject private var navigationRouter: NavigationRouter
    @ObservedObject private var viewModel: OtherProfileViewModel

    init(viewModel: OtherProfileViewModel, navigationRouter: NavigationRouter) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._navigationRouter = ObservedObject(wrappedValue: navigationRouter)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    title: "",
                    onBack: { viewModel.onBackTapped() },
                    rightButton: .menu(
                        imageName: "more",
                        isSystemIcon: false,
                        isEnabled: true
                    ) {
                        viewModel.showBlockMenu()
                    }
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        profileSection
                            .padding(.top, 32)

                        Divider()
                            .padding(.top, 24)
                            .foregroundStyle(Color.Codive.grayscale7)

                        if !viewModel.favoriteCoordinates.isEmpty {
                            favoriteCodiSection
                                .padding(.top, 24)
                        }

                        calendarSection
                            .padding(.top, 40)

                        Spacer(minLength: 40)
                    }
                }
            }

            if viewModel.isBlockMenuPresented {
                Color.black
                    .opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.dismissBlockMenu()
                    }

                BlockMenuPopup {
                    viewModel.onBlockTapped()
                }
                .padding(.trailing, 10)
                .padding(.top, 50)
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .enableSwipeBack()
        .task {
            await viewModel.loadProfile()
        }
        .onChange(of: viewModel.month) { _ in
            Task {
                await viewModel.loadMonthlyHistories()
            }
        }
        .alert(
            TextLiteral.Feed.blockAlertTitle,
            isPresented: $viewModel.showBlockAlert
        ) {
            Button(TextLiteral.Common.cancel, role: .cancel) {}
            Button(TextLiteral.Common.confirm, role: .destructive) {
                viewModel.confirmBlock()
            }
        } message: {
            Text(TextLiteral.Feed.blockAlertMessage(viewModel.displayName))
        }
        .alert(
            TextLiteral.Feed.blockFailureAlertTitle,
            isPresented: $viewModel.showBlockFailureAlert
        ) {
            Button(TextLiteral.Common.confirm, role: .cancel) {}
        } message: {
            Text(viewModel.blockErrorMessage)
        }
        .alert(
            "캘린더 로딩 실패",
            isPresented: $viewModel.showHistoryErrorAlert
        ) {
            Button(TextLiteral.Common.confirm, role: .cancel) {}
        } message: {
            Text("기록을 불러오는데 실패했습니다.")
        }
    }

    // MARK: - Profile
    private var profileSection: some View {
        VStack {
            if let urlString = viewModel.profileImageUrl, !urlString.isEmpty {
                AsyncImage(url: URL(string: urlString)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        Image("Profile")
                            .resizable()
                            .scaledToFill()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Image("Profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }

            Text(viewModel.displayName)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.top, 9)

            HStack(spacing: 20) {
                Button {
                    viewModel.onFollowerTapped()
                } label: {
                    HStack(spacing: 6) {
                        Text("팔로워")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                        Text("\(viewModel.followerCount)")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                    }
                }

                Button {
                    viewModel.onFollowingTapped()
                } label: {
                    HStack(spacing: 6) {
                        Text("팔로잉")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                        Text("\(viewModel.followingCount)")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                    }
                }
            }
            .padding(.top, 4)

            Text(viewModel.introText)
                .font(.codive_body2_regular)
                .foregroundStyle(Color.Codive.grayscale4)
                .padding(.top, 4)

            followButton
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
    }

    private var followButton: some View {
        let isFollowing = viewModel.isFollowing
        return Button {
            viewModel.onFollowButtonTapped()
        } label: {
            Text(isFollowing ? "팔로잉" : "팔로우")
                .font(.codive_body2_medium)
                .foregroundStyle(isFollowing ? Color.Codive.main0 : .white)
                .frame(width: 76, height: 32)
                .background(isFollowing ? .white : Color.Codive.main0)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isFollowing ? Color.Codive.main0 : .clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Favorite Codi
    private var favoriteCodiSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("최애 코디")
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)

                Spacer(minLength: 0)

                Button {
                    viewModel.onMoreFavoriteCodiTapped()
                } label: {
                    HStack(spacing: 6) {
                        Text("더보기")
                            .font(.codive_body2_regular)
                            .foregroundStyle(Color.Codive.grayscale3)
                        Image("go")
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.Codive.grayscale3)
                    }
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.favoriteCoordinates, id: \.coordinateId) { codi in
                        CodiCard(
                            imageURL: URL(string: codi.imageUrl),
                            title: nil,
                            icon: .none,
                            cardWidth: 160,
                            imageSize: 160,
                            cornerRadius: 16,
                            onCardTap: nil
                        )
                    }
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Calendar
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("캘린더")
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.horizontal, 20)

            CalendarMonthView(
                month: $viewModel.month,
                selectedDate: $viewModel.selectedDate,
                monthlyHistories: $viewModel.monthlyHistories
            )
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .codiveCardShadow()
                .padding(.horizontal, 20)
                .padding(.top, 12)
        }
    }
}

#Preview {
    EmptyView()
}
