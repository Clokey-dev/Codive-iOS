//
//  HomeHasCodiView.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import SwiftUI

struct HomeHasCodiView: View {
    @ObservedObject var viewModel: HomeViewModel
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader
            codiDisplayView
            clothSelectorView
            codiBanner
        }
    }

    private var sectionHeader: some View {
        HStack {
            Text("오늘의 코디 (08.18)")
                .font(Font.codive_title1)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.horizontal, 20)
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var codiDisplayView: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.Codive.grayscale7)
                .frame(width: width - 40, height: width - 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.Codive.grayscale5, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                .padding(.horizontal, 20)

            Button(action: viewModel.toggleClothSelector) {
                Image("ic_tag")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            .padding(.leading, 16)
            .padding()
        }
    }

    private var clothSelectorView: some View {
        Group {
            if viewModel.showClothSelector {
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        SelectableClothItem(
                            imageName: index == 3 ? nil : "cardigan",
                            isSelected: Binding(
                                get: { viewModel.selectedIndex == index },
                                set: { newValue in
                                    if newValue { viewModel.selectCloth(at: index) }
                                }
                            )
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var codiBanner: some View {
        CustomBanner(text: "오늘 이 코디를 기억하고 싶다면?") {
            print("Icon tapped!")
        }
        .padding()
    }
}
