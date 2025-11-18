//
//  HomeUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import CoreLocation

final class HomeUseCase {
    // MARK: - Properties
    private let repository: HomeRepository
    
    // MARK: - Initializer
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    // MARK: - Weather
    func execute(for location: CLLocation?) async throws -> WeatherData {
        return try await repository.fetchWeatherData(for: location)
    }
    
    // MARK: - Categories
    func loadCategories() -> [CategoryEntity] {
        return repository.fetchCategories()
    }
    
    func updateCategories(_ categories: [CategoryEntity]) {
        repository.saveCategories(categories)
    }
    
    // MARK: - Codi Items
    func loadCodiBoardImages() -> [DraggableImageEntity] {
        repository.fetchInitialImages()
    }
    
    func saveCodiItems(_ images: [DraggableImageEntity]) {
        repository.saveCodiItems(images)
    }
    
    // MARK: - Today Codi
    func loadTodaysCodi() -> [CodiItemEntity] {
        repository.fetchCodiItems()
    }
    
    // MARK: - Date
    func getToday() -> DateEntity {
        repository.getToday()
    }
}
