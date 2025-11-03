//
//  ReportPopup.swift
//  Codive
//
//  Created by 한태빈 on 10/14/25.
//

import SwiftUI

struct ReportPopupView: View {

    @ObservedObject var vm: ReportPopupViewModel
    var onClose: () -> Void = {}   // 닫기 액션

    var body: some View {
        ZStack(alignment: .topTrailing) {
            content
                .padding(.vertical, 52)
                .padding(.horizontal, 40)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.Codive.main1)
                    .padding(22)
                    .contentShape(Rectangle())
            }
        }
    }

    private var content: some View {
        VStack(alignment: .center, spacing: 16) {
            Image("warning")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            headerText
            middleText
            lastText
        }
    }

    private var headerText: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(vm.headerLine1)
                .font(Font.codive_title1)
                .foregroundStyle(Color.Codive.grayscale1)
            Text(vm.headerLine2)
                .font(Font.codive_title1)
                .foregroundStyle(Color.Codive.grayscale1)
        }
        .padding(.bottom, 8)
    }

    private var middleText: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(vm.middleLine1)
                .font(Font.codive_body1_regular)
                .foregroundStyle(Color.Codive.point1)
            Text(vm.middleLine2)
                .font(Font.codive_body1_regular)
                .foregroundStyle(Color.Codive.point1)
        }
        .padding(.bottom, 8)
    }

    private var lastText: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("확인 후 조치 예정이며, 필요 시\n고객센터로 문의해 주세요.")
                .font(Font.codive_body1_regular)
                .foregroundStyle(Color.Codive.grayscale2)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    VStack(spacing: 24) {
        ReportPopupView(
            vm: ReportPopupViewModel(
                target: .post,
                itemTitle: "9월 12일 기록",
                reason: "욕설/비방"
            )
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
