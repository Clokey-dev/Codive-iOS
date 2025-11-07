//
//  HomeViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI
import Foundation
import UIKit
import Combine
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var hasCodi: Bool = false
    @Published var selectedIndex: Int? = 0
    @Published var showClothSelector: Bool = false
    @Published var titleFrame: CGRect = .zero

    // ✅ 날씨 데이터 상태 추가
    @Published var weatherData: WeatherData?

    private let navigationRouter: NavigationRouter
    private let useCase: HomeUseCase

    init(navigationRouter: NavigationRouter, useCase: HomeUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }

    // ✅ WeatherKit 데이터 불러오기
    func loadWeather(for location: CLLocation) async {
        do {
            let data = try await useCase.execute(for: location)
            weatherData = data
        } catch {
            print("❌ Failed to fetch weather:", error)
        }
    }

    // MARK: - 기존 코드
    var menuActions: [() -> Void] {
        return [
            { print("코디 수정 tapped") },
            { print("룩북에 추가 tapped") },
            { print("코디 공유 tapped") }
        ]
    }

    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
        }
    }

    func selectCloth(at index: Int) {
        selectedIndex = index
    }

    func handleSearchTap() {
        print("검색 버튼 클릭")
    }

    func handleNotificationTap() {
        print("알림 버튼 클릭")
    }

    func handleCodiBoardTap() {
        navigationRouter.navigate(to: .codiBoard)
        print("코디보드 tapped")
    }

    func handleConfirmCodiTap() {
        print("이 코디 결정 tapped")
    }

    func handleEditCategory() {
        navigationRouter.navigate(to: .editCategory)
    }
}
