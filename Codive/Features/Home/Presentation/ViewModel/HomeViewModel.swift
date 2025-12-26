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
    @Published var hasCodi: Bool = true
    @Published var selectedIndex: Int? = 0
    @Published var showClothSelector: Bool = false
    @Published var titleFrame: CGRect = .zero
    @Published var weatherData: WeatherData?
    @Published var weatherErrorMessage: String?
    @Published var todayString: String = ""
    @Published var selectedItemID: Int?
    @Published var codiItems: [CodiItemEntity] = []
    @Published var activeCategories: [CategoryEntity] = []
    @Published var clothItemsByCategory: [Int: [HomeClothEntity]] = [:]
    
    // 팝업 관련 프로퍼티 추가
    @Published var showCompletePopUp: Bool = false
    @Published var completedCodiImageURL: String?
    
    let navigationRouter: NavigationRouter
    
    // MARK: - UseCases
    private let fetchWeatherUseCase: FetchWeatherUseCase
    private let todayCodiUseCase: TodayCodiUseCase
    private let dateUseCase: DateUseCase
    private let categoryUseCase: CategoryUseCase
    
    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        fetchWeatherUseCase: FetchWeatherUseCase,
        todayCodiUseCase: TodayCodiUseCase,
        dateUseCase: DateUseCase,
        categoryUseCase: CategoryUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.todayCodiUseCase = todayCodiUseCase
        self.dateUseCase = dateUseCase
        self.categoryUseCase = categoryUseCase
        
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
        let categories = categoryUseCase.loadCategories()
        activeCategories = categories
        
        let clothItems = categoryUseCase.loadClothItems()
        clothItemsByCategory = Dictionary(grouping: clothItems) { $0.categoryId }
    }

    // MARK: - 새로운 API 방식 (비동기)
    func loadActiveCategoriesWithAPI() async {
        let categories = categoryUseCase.loadCategories()
        activeCategories = categories
        
        // 각 카테고리별로 옷 아이템 로드
        var allClothItems: [HomeClothEntity] = []
        
        for category in categories {
            do {
                let items = try await categoryUseCase.loadClothItems(
                    lastClothId: nil,
                    size: 20,
                    categoryId: Int64(category.id),
                    season: nil
                )
                allClothItems.append(contentsOf: items)
            } catch {
                print("Failed to load cloth items for category \(category.id): \(error)")
            }
        }
        
        // 카테고리별로 그룹화
        clothItemsByCategory = Dictionary(grouping: allClothItems) { $0.categoryId }
    }

    // MARK: - 특정 카테고리만 로드
    func loadClothItems(for categoryId: Int) async {
        do {
            let items = try await categoryUseCase.loadClothItems(
                lastClothId: nil,
                size: 20,
                categoryId: Int64(categoryId),
                season: nil
            )
            
            // 해당 카테고리의 아이템 업데이트
            clothItemsByCategory[categoryId] = items
        } catch {
            print("Failed to load cloth items: \(error)")
        }
    }

    // MARK: - 페이지네이션 (더 불러오기)
    func loadMoreClothItems(for categoryId: Int) async {
        guard let existingItems = clothItemsByCategory[categoryId],
              let lastItem = existingItems.last else {
            return
        }
        
        do {
            let newItems = try await categoryUseCase.loadClothItems(
                lastClothId: Int64(lastItem.id),
                size: 20,
                categoryId: Int64(categoryId),
                season: nil
            )
            
            // 기존 아이템에 추가
            clothItemsByCategory[categoryId] = existingItems + newItems
        } catch {
            print("Failed to load more items: \(error)")
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
    
    // MARK: - Popup Actions
    func showCompletionPopup(imageURL: String?) {
        completedCodiImageURL = imageURL
        showCompletePopUp = true
    }
    
    func handlePopupRecord() {
        showCompletePopUp = false
        // 기록하기 로직 구현
        // 예: navigationRouter.navigate(to: .recordCodi)
    }
    
    func handlePopupClose() {
        showCompletePopUp = false
        completedCodiImageURL = nil
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
