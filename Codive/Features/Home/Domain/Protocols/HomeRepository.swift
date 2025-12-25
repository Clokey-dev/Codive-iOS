//
//  HomeRepository.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import CoreLocation

protocol HomeRepository {
    // MARK: - Weather
    func fetchWeatherData(for location: CLLocation?) async throws -> WeatherData
    
    // MARK: - Categories
    func fetchCategories() -> [CategoryEntity]
    func saveCategories(_ categories: [CategoryEntity])
    
    // MARK: - Cloth Items
    func fetchClothItems() -> [HomeClothEntity]
    func fetchClothItems(request: ClothListRequestDTO) async throws -> [HomeClothEntity]
    
    // MARK: - Initial Images
    func fetchInitialImages() -> [DraggableImageEntity]
    
    // MARK: - Codi Items
    func saveCodiCoordinate(_ request: CodiCoordinateRequestDTO) async throws
    func fetchCodiItems() -> [CodiItemEntity]
    
    // MARK: - Date
    func getToday() -> DateEntity
}
