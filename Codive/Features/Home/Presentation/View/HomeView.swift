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
    @StateObject private var viewModel: HomeViewModel
    @ObservedObject private var navigationRouter: NavigationRouter
    
    init(homeDIContainer: HomeDIContainer) {
        self.homeDIContainer = homeDIContainer
        self._navigationRouter = ObservedObject(wrappedValue: homeDIContainer.navigationRouter)
        _viewModel = StateObject(wrappedValue: homeDIContainer.makeHomeViewModel())
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            GeometryReader { outerGeometry in
                VStack(spacing: 0) {
                    ScrollView {
                        VStack {
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
                .background(alignment: .center) {
                    Color.white
                }
                .task {
                    await viewModel.loadWeather(for: nil)
                }
                .onChange(of: navigationRouter.currentDestination) { newDestination in
                    if newDestination == nil {
                        viewModel.loadActiveCategories()
                    }
                }
            }
            // 🔥 이게 없으면 push 안 됨
            .navigationDestination(for: AppDestination.self) { destination in
                homeDIContainer.homeViewFactory.makeView(for: destination)
            }
        }
    }
}
