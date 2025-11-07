//
//  HomeUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import CoreLocation

final class HomeUseCase {
    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    /// 현재 위치 기반 날씨 정보를 가져오는 UseCase
    func execute(for location: CLLocation) async throws -> WeatherData {
        return try await repository.fetchWeatherData(for: location)
    }
    
    // 카테고리 불러오기
    func loadCategories() -> [CategoryEntity] {
        return repository.fetchCategories()
    }
    
    // 각 카테고리 별 count update
    func updateCategories(_ categories: [CategoryEntity]) {
        repository.saveCategories(categories)
    }
    
    // 이미지 로드
    func loadCodiBoardImages() -> [DraggableImageEntity] {
        repository.fetchInitialImages()
    }

    // 이미지 저장
    func saveCodiItems(_ images: [DraggableImageEntity]) {
        repository.saveCodiItems(images)
    }
    
    func loadTodaysCodi() -> [CodiItemEntity] {
        repository.fetchCodiItems()
    }
    
    func getToday() -> DateEntity {
        repository.getToday()
    }
}
