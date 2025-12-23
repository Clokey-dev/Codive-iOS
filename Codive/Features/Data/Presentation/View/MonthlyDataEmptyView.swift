//
//  MonthlyDataEmptyView.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

struct MonthlyDataEmptyView: View {
    let reportTitle: String
    let onBack: () -> Void
    let onWriteFeed: () -> Void

    init(
        reportTitle: String = "9월 옷장 리포트",
        onBack: @escaping () -> Void = {},
        onWriteFeed: @escaping () -> Void = {}
    ) {
        self.reportTitle = reportTitle
        self.onBack = onBack
        self.onWriteFeed = onWriteFeed
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: reportTitle) {
                onBack()
            }
            .background(Color.white)

            Spacer()

            VStack(spacing: 8) {
                Text("리포트를 완성하기엔 히스토리가 적어요")
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .multilineTextAlignment(.center)

                Text("피드와 코드 기록이 쌓이면\n리포트가 완성돼요. 하나 기록해볼까요?")
                    .font(.codive_body2_regular)
                    .foregroundStyle(Color.Codive.grayscale3)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.horizontal, 48)

            buttonArea
                .padding(.top, 30)

            Spacer()
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }

    private var buttonArea: some View {
        GeometryReader { geo in
            let horizontalPadding: CGFloat = 20
            let buttonWidth = (geo.size.width - horizontalPadding * 2) / 2

            HStack {
                Spacer(minLength: horizontalPadding)

                CustomButton(text: "피드 작성하러 가기", widthType: .half) {
                    onWriteFeed()
                }
                .frame(width: buttonWidth)

                Spacer(minLength: horizontalPadding)
            }
        }
        .frame(height: 36)
    }
}

#Preview {
    MonthlyDataEmptyView(
        reportTitle: "9월 옷장 리포트",
        onBack: { print("back") },
        onWriteFeed: { print("write feed") }
    )
}
