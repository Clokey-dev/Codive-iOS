//
//  HomeRepository.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import CoreLocation

protocol HomeRepository {
    // MARK: - 날씨
    
    func fetchWeatherData(for location: CLLocation?) async throws -> WeatherData
    
    // MARK: - 코디가 없는 경우의 Home 관련
    
    func fetchClothItems(request: ClothListRequestDTO) async throws -> [HomeClothEntity]
    func createTodayDailyCodi(_ codi: TodayDailyCodi) async throws
    
    // MARK: - 코디보드
    
    func fetchInitialImages() -> [DraggableImageEntity]
    func saveCodiCoordinate(_ request: CodiCoordinateRequestDTO) async throws
    
    // MARK: - 코디가 있는 경우의 Home 관련
    
    func fetchCodiItems() -> [CodiItemEntity]
    func getToday() -> DateEntity
    func fetchLookBookList() async throws -> [LookBookBottomSheetEntity]
    
    // MARK: - 카테고리 수정 관련
    
    func fetchCategories() -> [CategoryEntity]
    func saveCategories(_ categories: [CategoryEntity])
}
