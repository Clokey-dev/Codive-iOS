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
    @Published var hasCodi: Bool = false
    @Published var selectedIndex: Int? = 0
    @Published var showClothSelector: Bool = false
    @Published var titleFrame: CGRect = .zero
    
    // 날씨 데이터 상태 추가
    @Published var weatherData: WeatherData?
    @Published var weatherErrorMessage: String?
    
    @Published var todayString: String = ""
    @Published var selectedItemID: Int?
    @Published var codiItems: [CodiItemEntity] = []
    
    private let navigationRouter: NavigationRouter
    private let useCase: HomeUseCase
    
    init(navigationRouter: NavigationRouter, useCase: HomeUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        
        loadDummyCodi()
        loadToday()
    }
    
    // WeatherKit 데이터 불러오기
    func loadWeather(for location: CLLocation?) async {
        do {
            // ⭐️ 수정: UseCase 호출 시 Optional location 전달
            let data = try await useCase.execute(for: location)
            weatherData = data
        } catch {
            print("Failed to fetch weather:", error)
            weatherErrorMessage = TextLiteral.Home.failWeather
        }
    }
    
    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
        }
    }
    
    func selectCloth(at index: Int) {
        selectedIndex = index
    }
    
    func handleSearchTap() {}
    
    func handleNotificationTap() {}
    
    func handleCodiBoardTap() {
        navigationRouter.navigate(to: .codiBoard)
    }
    
    func handleConfirmCodiTap() {
    }
    
    func handleEditCategory() {
        navigationRouter.navigate(to: .editCategory)
    }
    
    func loadDummyCodi() {
        codiItems = useCase.loadTodaysCodi()
    }
    
    func selectItem(_ id: Int?) {
        selectedItemID = id
    }
    
    func loadToday() {
        let entity = useCase.getToday()
        self.todayString = entity.formattedDate
    }
    
    func rememberCodi() {}
    
    func selectEditCodi() {}
    
    func addLookbook() {}
    
    func sharedCodi() {}
}
