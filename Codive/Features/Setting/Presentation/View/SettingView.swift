//
//  SettingView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct SettingView: View {

    @ObservedObject private var vm: SettingViewModel

    init(viewModel: SettingViewModel) {
        self.vm = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: TextLiteral.Setting.title) {
                // 뒤로가기 액션
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
            Text(TextLiteral.Setting.loginInfo)
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
            Text(TextLiteral.Setting.account)
                .font(.codive_title3)
                .foregroundStyle(Color.Codive.grayscale1)

            Divider()
                .background(Color.Codive.grayscale1)
                .padding(.bottom, 16)

            SettingRow(text: TextLiteral.Setting.likedRecords)
                .padding(.bottom, 12)

            SettingRow(text: TextLiteral.Setting.myComments)
                .padding(.bottom, 12)

            SettingRow(text: TextLiteral.Setting.blockedUsers)
        }
    }

    // MARK: - 섹션: 알림

    private var notificationSection: some View {
        VStack(alignment: .leading) {
            Text(TextLiteral.Setting.notification)
                .font(.codive_title3)
                .foregroundStyle(Color.Codive.grayscale1)

            Divider()
                .background(Color.Codive.grayscale1)
                .padding(.bottom, 16)

            HStack {
                Text(TextLiteral.Setting.pushNotification)
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
                Text(TextLiteral.Setting.marketingConsent)
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
            Text(TextLiteral.Setting.customerSupport)
                .font(.codive_title3)
                .foregroundStyle(Color.Codive.grayscale3)

            Divider()
                .background(Color.Codive.grayscale3)
                .padding(.bottom, 16)

            HStack {
                Text(TextLiteral.Setting.versionInfo)
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color.Codive.grayscale1)

                Spacer()

                Text("1.3.2")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color.Codive.grayscale3)
            }
            .padding(.bottom, 12)

            SettingRow(text: TextLiteral.Setting.inquiry)
                .padding(.bottom, 12)

            SettingRow(text: TextLiteral.Setting.logout)
                .padding(.bottom, 12)

            SettingRow(text: TextLiteral.Setting.withdraw)
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
