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
    
    // MARK: - 날씨
    
    func fetchWeatherData(for location: CLLocation?) async throws -> WeatherData {
        return try await dataSource.fetchWeatherData(for: location)
    }
    
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws {
        try await dataSource.postTodayTemp(request: request)
    }
    
    // MARK: - 코디가 없는 경우의 Home 관련
    
    /// 계절에 따른 카테고리별 옷 리스트 api 연결
    func fetchRecommendCategoryClothList(
        lastClothId: Int64?,
        size: Int,
        categoryId: Int64,
        season: Set<Season>
    ) async throws -> (content: [HomeClothEntity], isLast: Bool) {
        let dto = try await dataSource.fetchRecommendCategoryCloth(
            lastClothId: lastClothId,
            size: size,
            categoryId: categoryId,
            season: season
        )
        
        return (
            content: dto.content.map { $0.toEntity(categoryId: categoryId) },
            isLast: dto.isLast
        )
    }
    
    /// 오늘의 코디 생성
    func createTodayCoordinate(
        request: CreateTodayCoordinateRequestDTO
    ) async throws -> TodayCoordinateEntity {
        let dto = try await dataSource.createTodayCoordinate(request: request)
        return dto.toEntity()
    }
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinateClothes() async throws -> [TodayCoordinateClothEntity] {
        let dtos = try await dataSource.fetchTodayCoordinateClothes()
        return dtos.map { $0.toEntity() }
    }
}

extension HomeRepositoryImpl {
    func createTodayDailyCodi(_ codi: TodayDailyCodi) async throws {
        try await dataSource.createTodayDailyCodi(codi)
    }
    
    // MARK: - 코디보드
    
    func fetchInitialImages() -> [DraggableImageEntity] {
        dataSource.loadInitialImages()
    }
    
    func saveCodiCoordinate(_ request: CodiCoordinateRequestDTO) async throws {
        try await dataSource.saveCodiCoordinate(request)
    }
    
    // MARK: - 코디가 있는 경우의 Home 관련
    
    func fetchCodiItems() -> [CodiItemEntity] {
        dataSource.loadDummyCodiItems()
    }
    
    func getToday() -> DateEntity {
        dataSource.fetchToday()
    }
    
    func fetchLookBookList() async throws -> [LookBookBottomSheetEntity] {
        return try await dataSource.fetchLookBookList()
    }
    
    // MARK: - 카테고리 수정 관련
    func fetchCategories() -> [CategoryEntity] {
        return dataSource.loadCategories()
    }
    
    func saveCategories(_ categories: [CategoryEntity]) {
        dataSource.saveCategories(categories)
    }
}
