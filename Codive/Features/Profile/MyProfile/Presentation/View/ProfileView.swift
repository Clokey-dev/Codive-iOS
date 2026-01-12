//
//  ProfileView.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

// MARK: - View
struct ProfileView: View {
    @ObservedObject private var navigationRouter: NavigationRouter
    @StateObject private var viewModel: ProfileViewModel

    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(navigationRouter: navigationRouter))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                topBar

                profileSection
                    .padding(.top, 32)
                
                Divider()
                    .padding(.top, 24)
                    .foregroundStyle(Color.Codive.grayscale7)

                favoriteCodiSection
                    .padding(.top, 24)

                calendarSection
                    .padding(.top, 40)

                Spacer(minLength: 77)
            }
        }
        .background(Color.white)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 12) {

            Spacer(minLength: 0)

            Button {
                viewModel.onEditProfileTapped()
            } label: {
                Image("edit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }

            Button {
                viewModel.onSettingsTapped()
            } label: {
                Image("setting")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 27, height: 27)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Profile
    private var profileSection: some View {
        VStack {
            Image("CustomProfile")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())

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
        }
        .frame(maxWidth: .infinity)
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
                    ForEach(0..<8, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white)
                            .frame(width: 160, height: 160)
                            .overlay(alignment: .topTrailing) {
                                    Image("heart_on")
                                        .frame(width: 15, height: 18)
                                        .foregroundStyle(Color.Codive.point1)
                                        .padding(14)
                            }
                            .codiveCardShadow()
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

            CalendarMonthView(month: $viewModel.month, selectedDate: $viewModel.selectedDate)
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
    ProfileView(navigationRouter: NavigationRouter())
}
