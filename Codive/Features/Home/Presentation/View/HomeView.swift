//
//  HomeView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct TitleBoundsPreferenceKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>?
    
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

struct HomeView: View {
    @StateObject private var navigationRouter: NavigationRouter
    private let homeDIContainer: HomeDIContainer
    @StateObject private var viewModel: HomeViewModel
    
    init(homeDIContainer: HomeDIContainer) {
        self.homeDIContainer = homeDIContainer
        _navigationRouter = StateObject(wrappedValue: homeDIContainer.navigationRouter)
        _viewModel = StateObject(wrappedValue: HomeViewModel(navigationRouter: homeDIContainer.navigationRouter))
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            GeometryReader { outerGeometry in
                VStack(spacing: 0) {
                    ScrollView {
                        VStack {
                            /// 날씨
                            WeatherCardView()
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            
                            if viewModel.hasCodi {
                                hasCodiSection(width: outerGeometry.size.width)
                            } else {
                                noCodiSection
                            }
                        }
                        .overlayPreferenceValue(TitleBoundsPreferenceKey.self) { preferences in
                            GeometryReader { geometry in
                                if let anchor = preferences {
                                    let frame = geometry[anchor]
                                    CustomOverflowMenu(
                                        menuType: .coordination,
                                        menuActions: viewModel.menuActions
                                    )
                                    .position(
                                        x: geometry.size.width - 40,
                                        y: frame.midY
                                    )
                                }
                            }
                        }
                    }
                }
                .background(Color.white)
                .navigationDestination(for: AppDestination.self) { destination in
                    homeDIContainer.homeViewFactory.makeView(for: destination)
                }
            }
        }
    }
}

extension HomeView {
    /// 등록한 코디가 있는 경우
    private func hasCodiSection(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader
            codiDisplayView(width: width)
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
                .anchorPreference(
                    key: TitleBoundsPreferenceKey.self,
                    value: .bounds
                ) { $0 }
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private func codiDisplayView(width: CGFloat) -> some View {
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
    
    /// 등록한 코디가 없는 경우
    private var noCodiSection: some View {
        VStack {
            noCodiHeader
            categoryButtons
            codiClothList
            Spacer()
            bottomButtons
        }
    }

    private var noCodiHeader: some View {
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
