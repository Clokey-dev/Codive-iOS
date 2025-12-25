//
//  HomeRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import CoreLocation

final class HomeRepositoryImpl: HomeRepository {
    // MARK: - Properties
    private let dataSource: HomeDatasource
    
    // MARK: - Initializer
    init(dataSource: HomeDatasource) {
        self.dataSource = dataSource
    }
    
    // MARK: - Weather
    func fetchWeatherData(for location: CLLocation?) async throws -> WeatherData {
        return try await dataSource.fetchWeatherData(for: location)
    }
    
    // MARK: - Categories
    func fetchCategories() -> [CategoryEntity] {
        return dataSource.loadCategories()
    }
    
    func saveCategories(_ categories: [CategoryEntity]) {
        dataSource.saveCategories(categories)
    }

    // MARK: - Cloth Items
    func fetchClothItems() -> [HomeClothEntity] {
        dataSource.loadClothItems()
    }
    
    // MARK: - Codi Items
    func fetchInitialImages() -> [DraggableImageEntity] {
        dataSource.loadInitialImages()
    }
    
    func saveCodiCoordinate(_ request: CodiCoordinateRequestDTO) {
        dataSource.saveCodiCoordinate(request)
    }
    
    func fetchCodiItems() -> [CodiItemEntity] {
        dataSource.loadDummyCodiItems()
    }
    
    // MARK: - Date
    func getToday() -> DateEntity {
        dataSource.fetchToday()
    }
}
