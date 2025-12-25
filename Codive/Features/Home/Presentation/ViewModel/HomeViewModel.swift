//
//  HomeViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI
import UIKit
import Combine
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var hasCodi: Bool = false
    @Published var selectedIndex: Int? = 0
    @Published var showClothSelector: Bool = false
    @Published var titleFrame: CGRect = .zero
    @Published var weatherData: WeatherData?
    @Published var weatherErrorMessage: String?
    @Published var todayString: String = ""
    @Published var selectedItemID: Int?
    @Published var codiItems: [CodiItemEntity] = []
    @Published var activeCategories: [CategoryEntity] = []
    
    @AppStorage("SavedCategories") private var savedCategoriesData: Data?
    
    let navigationRouter: NavigationRouter
    
    // MARK: - UseCases
    private let fetchWeatherUseCase: FetchWeatherUseCase
    private let todayCodiUseCase: TodayCodiUseCase
    private let dateUseCase: DateUseCase
    
    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        fetchWeatherUseCase: FetchWeatherUseCase,
        todayCodiUseCase: TodayCodiUseCase,
        dateUseCase: DateUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.todayCodiUseCase = todayCodiUseCase
        self.dateUseCase = dateUseCase
        
        loadDummyCodi()
        loadToday()
        loadActiveCategories()
    }
    
    // MARK: - Data Loading
    func loadWeather(for location: CLLocation?) async {
        do {
            let data = try await fetchWeatherUseCase.execute(for: location)
            weatherData = data
        } catch {
            print("Failed to fetch weather:", error)
            weatherErrorMessage = TextLiteral.Home.failWeather
        }
    }

    func loadActiveCategories() {
        let allCategories: [CategoryEntity]
        if let data = savedCategoriesData,
           let decoded = try? JSONDecoder().decode([CategoryEntity].self, from: data) {
            allCategories = decoded
        } else {
            allCategories = [
                CategoryEntity(id: 1, title: "상의", itemCount: 1),
                CategoryEntity(id: 2, title: "바지", itemCount: 1),
                CategoryEntity(id: 3, title: "스커트", itemCount: 0),
                CategoryEntity(id: 4, title: "아우터", itemCount: 0),
                CategoryEntity(id: 5, title: "신발", itemCount: 1),
                CategoryEntity(id: 6, title: "가방", itemCount: 0),
                CategoryEntity(id: 7, title: "패션 소품", itemCount: 0)
            ]
        }
        
        activeCategories = allCategories.flatMap { category in
            Array(repeating: category, count: category.itemCount)
        }
    }
    
    func loadDummyCodi() {
        codiItems = todayCodiUseCase.loadTodaysCodi()
    }

    func loadToday() {
        let entity = dateUseCase.getToday()
        self.todayString = entity.formattedDate
    }
    
    // MARK: - UI Actions
    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
        }
    }
    
    func selectCloth(at index: Int) {
        selectedIndex = index
    }
    
    func selectItem(_ id: Int?) {
        selectedItemID = id
    }
    
    func handleSearchTap() {}
    
    func handleNotificationTap() {}
    
    // MARK: - Navigation
    func handleCodiBoardTap() {
        navigationRouter.navigate(to: .codiBoard)
    }
    
    func handleConfirmCodiTap() {
    }
    
    func handleEditCategory() {
        navigationRouter.navigate(to: .editCategory)
    }
    
    // MARK: - Lifecycle
    func onAppear() {
        loadActiveCategories()
    }
    
    // MARK: - Feature Placeholders
    func rememberCodi() {}
    
    func selectEditCodi() {}
    
    func addLookbook() {
        navigationRouter.navigate(to: .lookbook)
    }
    
    func sharedCodi() {}
}
