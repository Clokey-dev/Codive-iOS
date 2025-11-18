//
//  SettingView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct SettingView: View {

    @StateObject private var vm: SettingViewModel

    init(viewModel: SettingViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "설정") {
                // 뒤로가기 액션은 나중에 Router 연결
                print("뒤로가기")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    loginInfo
                    accountInfo
                    notificationSection
                    helpCustomer
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .task {
            await vm.load()
        }
    }

    // MARK: - 섹션: 로그인 / 회원정보

    private var loginInfo: some View {
        VStack(alignment: .leading) {
            Text("로그인/회원정보")
                .font(.codive_title3)
                .foregroundStyle(Color.Codive.grayscale1)

            Divider()
                .background(Color.Codive.grayscale1)
                .padding(.bottom, 16)

            HStack(spacing: 15) {
                Image("kakao")
                    .frame(width: 40, height: 40)

                Text("email@xxxx.com")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color.Codive.grayscale1)
            }
        }
    }

    // MARK: - 섹션: 계정

    private var accountInfo: some View {
        VStack(alignment: .leading) {
            Text("계정")
                .font(.codive_title3)
                .foregroundStyle(Color.Codive.grayscale1)

            Divider()
                .background(Color.Codive.grayscale1)
                .padding(.bottom, 16)

            SettingRow(text: "좋아요 한 기록")
                .padding(.bottom, 12)

            SettingRow(text: "내가 남긴 댓글")
                .padding(.bottom, 12)

            SettingRow(text: "차단한 계정")
        }
    }

    // MARK: - 섹션: 알림

    private var notificationSection: some View {
        VStack(alignment: .leading) {
            Text("알림")
                .font(.codive_title3)
                .foregroundStyle(Color.Codive.grayscale1)

            Divider()
                .background(Color.Codive.grayscale1)
                .padding(.bottom, 16)

            HStack {
                Text("PUSH 알림")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color.Codive.grayscale1)

                Spacer()

                // ViewModel 상태와 직접 바인딩 + 변경 시 저장
                PillToggle(
                    isOn: Binding(
                        get: { vm.isPushOn },
                        set: { vm.updatePush($0) }
                    )
                )
            }
            .padding(.bottom, 12)

            HStack {
                Text("마케팅 알림 수신 동의")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color.Codive.grayscale3)

                Spacer()

                PillToggle(
                    isOn: Binding(
                        get: { vm.isMarketingOn },
                        set: { vm.updateMarketing($0) }
                    )
                )
            }
        }
    }

    // MARK: - 섹션: 고객 지원

    private var helpCustomer: some View {
        VStack(alignment: .leading) {
            Text("고객 지원")
                .font(.codive_title3)
                .foregroundStyle(Color.Codive.grayscale3)

            Divider()
                .background(Color.Codive.grayscale3)
                .padding(.bottom, 16)

            HStack {
                Text("버전 정보")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color.Codive.grayscale1)

                Spacer()

                Text("1.3.2")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color.Codive.grayscale3)
            }
            .padding(.bottom, 12)

            SettingRow(text: "문의하기")
                .padding(.bottom, 12)

            SettingRow(text: "로그아웃")
                .padding(.bottom, 12)

            SettingRow(text: "계정 탈퇴")
        }
    }
}

// MARK: - 공용 Row

private struct SettingRow: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .font(.codive_body1_regular)
                .foregroundStyle(Color.Codive.grayscale1)

            Spacer()

            Image("backSmall")
                .frame(width: 6, height: 12)
                .foregroundStyle(Color.Codive.main1)
        }
    }
}
