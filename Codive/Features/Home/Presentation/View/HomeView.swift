//
//  HomeView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject private var navigationRouter: NavigationRouter
    private let homeDIContainer: HomeDIContainer
    @StateObject private var viewModel: HomeViewModel

    init(homeDIContainer: HomeDIContainer) {
        self.homeDIContainer = homeDIContainer
        _navigationRouter = StateObject(wrappedValue: homeDIContainer.navigationRouter)
        _viewModel = StateObject(wrappedValue: homeDIContainer.makeHomeViewModel())
    }

    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            GeometryReader { outerGeometry in
                VStack(spacing: 0) {
                    ScrollView {
                        VStack {
                            // Weather 출력
                            if let weather = viewModel.weatherData {
                                WeatherCardView(weatherData: weather)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                            } else {
                                if let errorMessage = viewModel.weatherErrorMessage {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 16)
                                        .padding(.horizontal, 20)
                                } else {
                                    ProgressView(TextLiteral.Home.weatherLoading)
                                        .padding(.top, 16)
                                }
                            }

                            // 리팩토링한 분리 뷰
                            if viewModel.hasCodi {
                                HomeHasCodiView(
                                    viewModel: viewModel,
                                    width: outerGeometry.size.width
                                )
                            } else {
                                HomeNoCodiView(viewModel: viewModel)
                            }
                        }
                    }
                }
                .background(Color.white)
                .navigationDestination(for: AppDestination.self) { destination in
                    homeDIContainer.homeViewFactory.makeView(for: destination)
                }
                .task {
                    let location = CLLocation(latitude: 37.5665, longitude: 126.9780)
                    await viewModel.loadWeather(for: location)
                }
            }
        }
    }
}
