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
    
    init(homeDIContainer: HomeDIContainer, viewModel: HomeViewModel) {
        self.homeDIContainer = homeDIContainer
        self.viewModel = viewModel
        self._navigationRouter = ObservedObject(wrappedValue: homeDIContainer.navigationRouter)
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
                                width: outerGeometry.size.width
                            )
                        } else {
                            HomeNoCodiView(viewModel: viewModel)
                        }
                    }
                    .padding(.bottom, 16)
                }
                .id(scrollViewID)
            }
            .task {
                await viewModel.loadWeather(for: nil)
                // 오늘의 코디 여부 확인 (추가)
                viewModel.fetchTodayCodiData()
//                await viewModel.loadActiveCategoriesWithAPI()
            }
            .onChange(of: navigationRouter.currentDestination) { newDestination in
                if newDestination == nil {
                    viewModel.loadActiveCategories()
                    // 홈으로 돌아올 때 스크롤 초기화
                    scrollViewID = UUID()
                }
            }
        }
    }
}
