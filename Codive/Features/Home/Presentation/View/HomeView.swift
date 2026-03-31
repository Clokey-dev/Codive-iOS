//
//  HomeView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    private let homeDIContainer: HomeDIContainer
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject private var navigationRouter: NavigationRouter
    @State private var scrollViewID = UUID()
    let onBannerTapped: () -> Void

    init(homeDIContainer: HomeDIContainer, viewModel: HomeViewModel, onBannerTapped: @escaping () -> Void) {
        self.homeDIContainer = homeDIContainer
        self.viewModel = viewModel
        self._navigationRouter = ObservedObject(wrappedValue: homeDIContainer.navigationRouter)
        self.onBannerTapped = onBannerTapped
    }
    
    var body: some View {
        GeometryReader { outerGeometry in
            ZStack {
                // 전체 배경
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        // 날씨 카드
                        if let weather = viewModel.weatherData {
                            WeatherCardView(weatherData: weather)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                        } else {
                            if let errorMessage = viewModel.weatherErrorMessage {
                                Text(errorMessage)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 16)
                                    .padding(.horizontal, 20)
                            } else {
                                ProgressView(TextLiteral.Home.weatherLoading)
                                    .padding(.top, 16)
                            }
                        }
                        
                        // 코디 여부에 따라 다른 뷰
                        if viewModel.hasCodi {
                            HomeHasCodiView(
                                viewModel: viewModel,
                                width: outerGeometry.size.width,
                                onBannerTapped: onBannerTapped
                            )
                            .transition(.opacity)
                        } else {
                            HomeNoCodiView(viewModel: viewModel)
                                .transition(.opacity)
                        }
                    }
                    .padding(.bottom, 16)
                }
                .id(scrollViewID)
            }
            .task {
                await viewModel.loadWeather(for: nil)
                if !viewModel.isEditingExistingCodi {
                    viewModel.fetchTodayCodiData()
                }
            }
            .onAppear {
                // 다른 탭/화면에서 돌아올 때 오늘의 코디 및 옷 목록 갱신
                if viewModel.weatherData != nil {
                    if !viewModel.isEditingExistingCodi {
                        viewModel.fetchTodayCodiData()
                    }
                    Task {
                        await viewModel.loadRecommendCategoryClothList(seasons: viewModel.currentSeasons)
                    }
                }
            }
            .onReceive(viewModel.$needsScrollReset) { needsReset in
                if needsReset {
                    scrollViewID = UUID()
                    viewModel.needsScrollReset = false
                }
            }
        }
    }
}
