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
        Text(TextLiteral.Home.noCodiTitle)
            .font(Font.codive_title1)
            .foregroundStyle(Color.Codive.grayscale1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 24, leading: 20, bottom: 16, trailing: 20))
    }

    private var categoryButtons: some View {
        HStack(spacing: 8) {
            CodiButton(iconName: "plus", title: TextLiteral.Home.edit) {
                viewModel.handleEditCategory()
            }
            CodiButton(iconName: "shuffle", title: TextLiteral.Home.random) {}
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
                text: TextLiteral.Home.codiBoardTitle,
                widthType: .half,
                action: viewModel.handleCodiBoardTap
            )
            CustomButton(
                text: TextLiteral.Home.decesion,
                widthType: .half,
                action: viewModel.handleConfirmCodiTap
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .padding(.bottom, 100)
    }
}
