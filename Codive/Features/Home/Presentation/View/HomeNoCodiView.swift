//
//  HomeNoCodiView.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import SwiftUI

struct HomeNoCodiView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack {
            header
            categoryButtons
            codiClothList
            Spacer()
            bottomButtons
        }
    }

    private var header: some View {
        Text("오늘 날씨에 이 코디 어때요?")
            .font(Font.codive_title1)
            .foregroundStyle(Color.Codive.grayscale1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 24, leading: 20, bottom: 16, trailing: 20))
    }

    private var categoryButtons: some View {
        HStack(spacing: 8) {
            CodiButton(iconName: "plus", title: "카테고리 편집") {
                viewModel.handleEditCategory()
            }
            CodiButton(iconName: "shuffle", title: "랜덤 코디") {}
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 16)
    }

    private var codiClothList: some View {
        VStack(spacing: 16) {
            CodiClothView(title: "상의")
            CodiClothView(title: "바지")
            CodiClothView(title: "신발")
        }
        .padding(.horizontal, 20)
    }

    private var bottomButtons: some View {
        HStack(spacing: 16) {
            CustomButton(
                text: "코디보드",
                widthType: .half,
                action: viewModel.handleCodiBoardTap
            )
            CustomButton(
                text: "이 코디로 결정하기",
                widthType: .half,
                action: viewModel.handleConfirmCodiTap
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .padding(.bottom, 100)
    }
}
