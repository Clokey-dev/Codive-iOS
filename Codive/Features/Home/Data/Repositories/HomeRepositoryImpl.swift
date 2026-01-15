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
    
    // 새로운 API 기반 메서드
    func fetchClothItems(request: ClothListRequestDTO) async throws -> [HomeClothEntity] {
        let dtoList = try await dataSource.fetchClothItems(request: request)
        
        // categoryId를 request에서 가져오거나 기본값 사용
        let categoryId = Int(request.categoryId ?? 1)
        return dtoList.toEntities(categoryId: categoryId)
    }
    
    // MARK: - Codi Items
    func fetchInitialImages() -> [DraggableImageEntity] {
        dataSource.loadInitialImages()
    }
    
    func saveCodiCoordinate(_ request: CodiCoordinateRequestDTO) async throws {
            try await dataSource.saveCodiCoordinate(request)
        }
    
    func fetchCodiItems() -> [CodiItemEntity] {
        dataSource.loadDummyCodiItems()
    }
    
    // MARK: - Date
    func getToday() -> DateEntity {
        dataSource.fetchToday()
    }
    
    func fetchLookBookList() async throws -> [LookBookBottomSheetEntity] {
        return try await dataSource.fetchLookBookList()
    }
    
    func createTodayDailyCodi(_ codi: TodayDailyCodi) async throws {
        try await dataSource.createTodayDailyCodi(codi)
    }
}
