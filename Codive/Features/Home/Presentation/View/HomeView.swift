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
                    .padding(.bottom, 16)   // 필요하면 살짝만 여백
                }
                .id(scrollViewID)
                
                // 팝업 오버레이
                if viewModel.showCompletePopUp {
                    CompletePopUp(
                        isPresented: $viewModel.showCompletePopUp,
                        onRecordTapped: viewModel.handlePopupRecord,
                        onCloseTapped: viewModel.handlePopupClose,
                        imageURL: viewModel.completedCodiImageURL
                    )
                    .zIndex(1)
                }
            }
            .task {
                await viewModel.loadWeather(for: nil)
                await viewModel.loadActiveCategoriesWithAPI()
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
