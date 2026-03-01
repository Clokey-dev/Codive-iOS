//
//  ProfileSettingView.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI
import Combine
import PhotosUI

struct ProfileSettingView: View {
    @ObservedObject private var navigationRouter: NavigationRouter
    @ObservedObject private var viewModel: ProfileSettingViewModel

    init(viewModel: ProfileSettingViewModel, navigationRouter: NavigationRouter) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._navigationRouter = ObservedObject(wrappedValue: navigationRouter)
    }

    enum Field: Hashable {
        case nickname
        case intro
    }

    @FocusState private var focus: Field?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    title: "프로필 설정",
                    onBack: { navigationRouter.navigateBack() },
                    rightButton: .text(
                        title: "완료",
                        isEnabled: viewModel.canComplete && !viewModel.isLoading,
                        action: viewModel.onCompleteTapped
                    )
                )

                if viewModel.isLoadingProfile {
                    VStack {
                        ProgressView()
                            .tint(.black)
                        Text("프로필 정보 로딩 중...")
                            .font(.codive_body3_medium)
                            .foregroundStyle(Color.Codive.grayscale4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            profileImageSection
                                .padding(.top, 32)

                            formSection
                                .padding(.top, 56)

                            Spacer(minLength: 120)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.hideKeyboard()
                    }
                    .opacity(viewModel.isLoading ? 0.5 : 1)
                    .disabled(viewModel.isLoading)
                }
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
        .enableSwipeBack {
            navigationRouter.navigateBack()
        }
        .onAppear {
            Task {
                await viewModel.loadCurrentProfile()
            }
        }
    }

    private var profileImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            profileImageContent
                .frame(width: 100, height: 100)
                .clipShape(Circle())

            PhotosPicker(
                selection: $viewModel.selectedPhotoPickerItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Circle()
                    .fill(Color.Codive.grayscale1)
                    .frame(width: 28, height: 28)
                    .overlay {
                        Image("plus")
                            .frame(width: 28, height: 28)
                    }
            }
            .buttonStyle(.plain)
            .offset(x: 6, y: 6)
            .onChange(of: viewModel.selectedPhotoPickerItem) { newValue in
                Task {
                    await viewModel.handlePhotoSelection(newValue)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            UnderlineField(
                title: "닉네임",
                requiredTag: "*",
                text: $viewModel.nickname,
                focus: $focus,
                focusEquals: .nickname,
                keyboardType: .default
            ) {
                Button {
                    viewModel.runNicknameDuplicateCheck()
                } label: {
                    Text("중복 확인")
                        .font(.codive_body3_medium)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.Codive.grayscale4, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canTryNicknameCheck)
                .opacity(viewModel.canTryNicknameCheck ? 1 : 0.4)
            }
            .setHelper(
                emptyText: "한글, 소문자, 숫자 조합, 20자 이내",
                filledText: viewModel.nicknameFilledHelper,
                errorText: viewModel.nicknameErrorText
            )
            .padding(.top, 18)

            UnderlineField(
                title: "한줄소개",
                requiredTag: nil,
                text: $viewModel.intro,
                focus: $focus,
                focusEquals: .intro,
                keyboardType: .default
            )
            .setHelper(
                emptyText: "20자 이내로 나를 소개 해보세요.",
                filledText: nil,
                errorText: viewModel.introErrorText
            )
            .padding(.top, 26)

            privacySection
                .padding(.top, 26)
        }
        .padding(.horizontal, 20)
    }

    private var profileImageContent: some View {
        if let pickedProfileImage = viewModel.pickedProfileImage {
            // 사용자가 방금 선택한 이미지
            return AnyView(
                pickedProfileImage
                    .resizable()
                    .scaledToFill()
            )
        } else if let imageUrl = viewModel.currentProfileImageUrl, !imageUrl.isEmpty {
            // 저장된 프로필 이미지 URL
            return AnyView(
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty:
                        ProgressView()
                    case .failure:
                        Image("Profile")
                            .resizable()
                            .scaledToFill()
                    @unknown default:
                        Image("Profile")
                            .resizable()
                            .scaledToFill()
                    }
                }
            )
        } else {
            // 기본 이미지 (프로필 이미지가 없을 때)
            return AnyView(
                Image("Profile")
                    .resizable()
                    .scaledToFill()
            )
        }
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("계정 공개여부")
                    .font(.codive_body1_medium)
                    .foregroundStyle(Color.Codive.grayscale1)

                Text("*")
                    .font(.codive_body3_medium)
                    .foregroundStyle(Color.Codive.point1)
            }

            HStack(spacing: 10) {
                pillButton(title: "공개", isOn: viewModel.isPublic) { viewModel.isPublic = true }
                pillButton(title: "비공개", isOn: !viewModel.isPublic) { viewModel.isPublic = false }
                Spacer(minLength: 0)
            }
        }
    }

    private func pillButton(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.codive_body2_medium)
                .foregroundStyle(isOn ? Color.Codive.point1 : Color.Codive.grayscale3)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isOn ? Color.Codive.point4 : Color.Codive.grayscale7)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isOn ? Color.Codive.point2 : Color.Codive.grayscale6, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EmptyView()
}
