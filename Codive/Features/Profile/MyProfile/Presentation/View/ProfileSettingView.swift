//
//  ProfileSettingView.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI
import Combine

struct ProfileSettingView: View {
    @ObservedObject private var navigationRouter: NavigationRouter
    @ObservedObject private var viewModel: ProfileSettingViewModel

    init(viewModel: ProfileSettingViewModel, navigationRouter: NavigationRouter) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.navigationRouter = navigationRouter
    }

    enum Field: Hashable {
        case nickname
        case intro
    }

    @FocusState private var focus: Field?

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "프로필 설정",
                onBack: { navigationRouter.navigateBack() },
                rightButton: .none
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    profileImageSection
                        .padding(.top, 32)

                    formSection
                        .padding(.top, 56)

                    completeButton
                        .padding(.top, 120)
                }
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }

    private var profileImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let pickedProfileImage = viewModel.pickedProfileImage {
                    pickedProfileImage
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("Profile")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())

            Button {
                viewModel.onProfileImageTapped()
            } label: {
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

    private var completeButton: some View {
        CustomButton(
            text: "설정 완료",
            widthType: .fixed,
            isEnabled: viewModel.canComplete
        ) {
            viewModel.onCompleteTapped()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ProfileSettingView(navigationRouter: NavigationRouter())
}
