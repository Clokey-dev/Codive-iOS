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
    @ObservedObject private var viewModel: ProfileViewModel
    @EnvironmentObject private var mainTabViewModel: MainTabViewModel

    init(viewModel: ProfileViewModel, navigationRouter: NavigationRouter) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._navigationRouter = ObservedObject(wrappedValue: navigationRouter)
    }
    
    var body: some View {
        GeometryReader { _ in
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
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color.white)
            .task {
                await viewModel.loadMyProfile()
            }

            if viewModel.isShowingPopup, let preview = viewModel.selectedCoordinatePreview {
                FavoriteLookBookPopUp(
                    imageUrl: preview.imageUrl,
                    clothItems: viewModel.popupClothItems,
                    payloads: viewModel.popupPayloads
                ) {
                    viewModel.isShowingPopup = false
                }
                .transition(.opacity.combined(with: .scale))
                .zIndex(1)
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(!navigationRouter.path.isEmpty)
        .enableSwipeBack()
        .task {
            // 콜백 설정: 기록이 없는 날짜가 선택되면 모달 표시
            viewModel.onEmptyHistoryDateSelected = { [weak mainTabViewModel] date in
                mainTabViewModel?.emptyHistoryModalDate = date
                mainTabViewModel?.isEmptyHistoryModalPresented = true
            }
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 12) {
            // 뒤로가기 버튼: 네비게이션으로 들어왔을 때만 표시
            if !navigationRouter.path.isEmpty {
                Button {
                    navigationRouter.navigateBack()
                } label: {
                    Image("back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.Codive.grayscale3)
                }
            }

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
            if let profileImageUrl = viewModel.profileImageUrl, let url = URL(string: profileImageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    case .empty, .failure:
                        Image("Profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    @unknown default:
                        Image("Profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    }
                }
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
                .foregroundStyle(Color.Codive.grayscale3)
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

                if !viewModel.favoriteCoordinates.isEmpty {
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
            }
            .padding(.horizontal, 20)
            
            if viewModel.favoriteCoordinates.isEmpty {
                favoriteCodiEmptyCard
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.favoriteCoordinates, id: \.coordinateId) { codi in
                            CodiCard(
                                imageURL: URL(string: codi.imageUrl),
                                title: nil,
                                icon: .heart(isSelected: true) {},
                                cardWidth: 160,
                                imageSize: 160,
                                cornerRadius: 16,
                                iconPadding: 14,
                                iconSize: 20
                            ) {
                                viewModel.onCodiCardTapped(coordinateId: Int64(codi.coordinateId))
                            }
                        }
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Favorite Codi Empty
    private var favoriteCodiEmptyCard: some View {
        VStack(spacing: 8) {
            Text("최애 코디가 아직 없어요")
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)

            Text("옷장에서 좋아하는 코디에 하트를 눌러\n최애 코디를 채워보세요!")
                .font(.codive_body2_regular)
                .foregroundStyle(Color.Codive.grayscale1)
                .multilineTextAlignment(.center)

            Button {
                mainTabViewModel.selectedTab = .closet
            } label: {
                Text("옷장으로 이동하기")
                    .font(.codive_title2)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.Codive.main0)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.Codive.grayscale6, lineWidth: 1)
                )
        )
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
