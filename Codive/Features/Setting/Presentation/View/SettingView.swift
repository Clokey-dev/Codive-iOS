//
//  SettingView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct SettingView: View {
    @State private var isOn = false

    var body: some View {
        CustomNavigationBar(title: "설정") {
            print("뒤로가기")
        }
        VStack(alignment: .leading, spacing: 40) {
            loginInfo
            accountInfo
            notification
            helpCustomer
        }
        .padding(.horizontal, 20)
    }
    
    private var loginInfo: some View {
        VStack(alignment: .leading) {
            Text("로그인/회원정보")
                .font(.codive_title3)
                .foregroundStyle(Color("Grayscale1"))
            Divider()
                .background(Color("Grayscale1"))
                .padding(.bottom, 16)
            HStack(spacing: 15) {
                Image("kakao")
                    .frame(width: 40, height: 40)
            Text("email@xxxx.com")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color("Grayscale1"))
            }
        }
    }
    
    private var accountInfo: some View {
        VStack(alignment: .leading) {
            Text("계정")
                .font(.codive_title3)
                .foregroundStyle(Color("Grayscale1"))
            Divider()
                .background(Color("Grayscale1"))
                .padding(.bottom, 16)
            SettingRow(text: "좋아요 한 기록")
                .padding(.bottom, 12)
            SettingRow(text: "내가 남긴 댓글")
                .padding(.bottom, 12)
            SettingRow(text: "차단한 계정")
        }
    }
    
    private var notification: some View {
        VStack(alignment: .leading) {
            Text("고객 지원")
                .font(.codive_title3)
                .foregroundStyle(Color("Grayscale1"))
            Divider()
                .background(Color("Grayscale1"))
                .padding(.bottom, 16)
            HStack {
                Text("PUSH 알림")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color("Grayscale1"))
                
                Spacer()
                
                PillToggle(isOn: $isOn)
            }
            .padding(.bottom, 12)
            HStack {
                Text("마케팅 알림 수신 동의")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color("Grayscale1"))
                
                Spacer()
                
                PillToggle(isOn: $isOn)
            }
        }
    }
    
    private var helpCustomer: some View {
        VStack(alignment: .leading) {
            Text("고객 지원")
                .font(.codive_title3)
                .foregroundStyle(Color("Grayscale1"))
            Divider()
                .background(Color("Grayscale1"))
                .padding(.bottom, 16)
            HStack {
                Text("버전 정보")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color("Grayscale1"))
                
                Spacer()
                
                Text("1.3.2")
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color("Grayscale3"))
            }
            .padding(.bottom, 12)
            SettingRow(text: "문의하기")
                .padding(.bottom, 12)
            SettingRow(text: "로그아웃")
                .padding(.bottom, 12)
            SettingRow(text: "계정 탈퇴")
        }
    }

    private struct SettingRow: View {
        let text: String
        var body: some View {
            HStack {
                Text(text)
                    .font(.codive_body1_regular)
                    .foregroundStyle(Color("Grayscale1"))
                
                Spacer()
                
                Image("backSmall")
                    .frame(width: 6, height: 12)
                    .foregroundStyle(Color("main1"))
            }
        }
    }
}

#Preview {
    SettingView()
}
