//
//  HomeRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import CoreLocation

final class HomeRepositoryImpl: HomeRepository {
    private let dataSource: HomeDatasource
    
    init(dataSource: HomeDatasource) {
        self.dataSource = dataSource
    }

    func fetchWeatherData(for location: CLLocation) async throws -> WeatherData {
        return try await dataSource.fetchWeatherData(for: location)
    }
    
    func fetchCategories() -> [CategoryEntity] {
        return dataSource.loadCategories()
    }
    
    func saveCategories(_ categories: [CategoryEntity]) {
        dataSource.saveCategories(categories)
    }
    
    func fetchInitialImages() -> [DraggableImageEntity] {
        dataSource.loadInitialImages()
    }
    
    func saveImages(_ images: [DraggableImageEntity]) {
        dataSource.saveCodiResult(images)
    }
}
