//
//  OtherProfileView.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

struct OtherProfileView: View {

    // MARK: - Mock (나중에 API로 교체)
    private let username: String = "ham_dog"
    private let displayName: String = "햄스터강아지"
    private let introText: String = "햄스터가 되고 싶은 강아지입니다"
    private let followerCount: Int = 22
    private let followingCount: Int = 20

    // MARK: - State
    @State private var isFollowing: Bool = false
    @State private var month: Date = Date()
    @State private var selectedDate: Date? = Date()

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
        HStack(spacing: 17) {
            Button {
                // back action
            } label: {
                Image("back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }

            Text(username)
                .font(.codive_title1)
                .foregroundStyle(Color.Codive.grayscale1)

            Spacer(minLength: 0)

            Button {
                // more action
            } label: {
                Image("more")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
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

            Text(displayName)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.top, 9)

            HStack(spacing: 20) {
                Button {
                    // follower tap
                } label: {
                    HStack(spacing: 6) {
                        Text("팔로워")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                        Text("\(followerCount)")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                    }
                }

                Button {
                    // following tap
                } label: {
                    HStack(spacing: 6) {
                        Text("팔로잉")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                        Text("\(followingCount)")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                    }
                }
            }
            .padding(.top, 4)

            Text(introText)
                .font(.codive_body2_regular)
                .foregroundStyle(Color.Codive.grayscale4)
                .padding(.top, 4)

            followButton
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
    }

    private var followButton: some View {
        Button {
            isFollowing.toggle()
        } label: {
            Text(isFollowing ? "팔로잉" : "팔로우")
                .font(.codive_body2_medium)
                .foregroundStyle(Color.white)
                .frame(width: 76, height: 32)
                .background(isFollowing ? Color.Codive.main0 : Color.Codive.main4)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Favorite Codi (ProfileView와 동일)
    private var favoriteCodiSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("최애 코디")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.Codive.grayscale1)

                Spacer(minLength: 0)

                Button {
                    // 더보기
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
                            .frame(width: 155, height: 155)
                            .codiveCardShadow()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Calendar
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("캘린더")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.horizontal, 20)

            CalendarMonthView(month: $month, selectedDate: $selectedDate)
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .codiveCardShadow()
                .padding(.horizontal, 20)
        }
    }
}
#Preview {
    OtherProfileView()
}
