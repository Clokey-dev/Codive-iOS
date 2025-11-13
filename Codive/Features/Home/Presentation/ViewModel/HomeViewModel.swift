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
    
    private let navigationRouter: NavigationRouter
    private let useCase: HomeUseCase
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, useCase: HomeUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        
        loadDummyCodi()
        loadToday()
        loadActiveCategories()
    }
    
    // MARK: - Data Loading
    func loadWeather(for location: CLLocation?) async {
        do {
            let data = try await useCase.execute(for: location)
            weatherData = data
        } catch {
            print("Failed to fetch weather:", error)
            weatherErrorMessage = TextLiteral.Home.failWeather
        }
    }

    func loadActiveCategories() {
        let allCategories = useCase.loadCategories()
        // itemCount가 0보다 큰 카테고리만 필터링
        activeCategories = allCategories.filter { $0.itemCount > 0 }
    }
    func loadDummyCodi() {
        codiItems = useCase.loadTodaysCodi()
    }

    func loadToday() {
        let entity = useCase.getToday()
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
    
    func addLookbook() {}
    
    func sharedCodi() {}
}
