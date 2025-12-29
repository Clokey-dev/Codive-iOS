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
            if !viewModel.isAllCategoriesEmpty {
                bottomButtons
            }
        }
        .onAppear {
            viewModel.onAppear()
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
            ForEach(viewModel.activeCategories) { category in
                let clothItems = viewModel.clothItemsByCategory[category.id] ?? []
                
                CodiClothView(
                    title: category.title,
                    items: clothItems,
                    isEmptyState: clothItems.isEmpty
                )
                .id("\(category.id)-\(clothItems.count)")
            }
        }
        .padding(.horizontal, 20)
    }

    // TODO: CustomButton에 비율 지정 기능 추가 후 리팩토링 필요
    private var bottomButtons: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width - 40
            let availableWidth = totalWidth - 16
            let button1Width = availableWidth / 3
            let button2Width = availableWidth * 2 / 3

            HStack(spacing: 16) {
                Button(action: viewModel.handleCodiBoardTap) {
                    Text(TextLiteral.Home.codiBoardTitle)
                        .font(Font.codive_title2)
                        .foregroundStyle(Color.Codive.main0)
                        .frame(width: button1Width, height: 48)
                }
                .background(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.Codive.main0, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button(action: viewModel.handleConfirmCodiTap) {
                    Text(TextLiteral.Home.decesion)
                        .font(Font.codive_title2)
                        .foregroundStyle(.white)
                        .frame(width: button2Width, height: 48)
                }
                .background(Color.Codive.main0)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 48)
        .padding(.top, 24)
        .padding(.bottom, 48)
    }
}
