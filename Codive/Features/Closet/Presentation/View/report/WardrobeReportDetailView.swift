//
//  WardrobeReportDetailView.swift
//  Codive
//
//  Created by claude on 2/26/26.
//

import SwiftUI

struct WardrobeReportDetailView: View {

    // MARK: - Properties
    @StateObject private var viewModel: WardrobeReportDetailViewModel

    // MARK: - Initializer
    init(viewModel: WardrobeReportDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "\(viewModel.currentMonth)월 옷장 리포트",
                onBack: {
                    viewModel.navigateBack()
                }
            )

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if !viewModel.canAggregate {
                insufficientDataView
            } else {
                // TODO: 통계 데이터 표시 (추후 구현)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.checkCondition()
        }
    }

    // MARK: - Insufficient Data View
    private var insufficientDataView: some View {
        VStack(spacing: 8) {
            Spacer()

            Text("리포트를 완성하기엔\n히스토리가 적어요")
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)
                .multilineTextAlignment(.center)

            Text("피드와 코디 기록이 쌓이면\n리포트가 완성돼요. 하나 기록해볼까요?")
                .font(.codive_body2_regular)
                .foregroundStyle(Color.Codive.grayscale3)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            CustomButton(
                text: "피드 작성하러 가기",
                widthType: .dynamic
            ) {
                viewModel.navigateToRecordAdd()
            }
            .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
