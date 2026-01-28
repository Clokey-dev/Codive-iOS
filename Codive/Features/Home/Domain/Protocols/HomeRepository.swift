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
    
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws
    
    // MARK: - 코디가 없는 경우의 Home 관련
    
    /// 날씨에 따른 카테고리별 옷 리스트 api 연결
    func fetchRecommendCategoryClothList(
        lastClothId: Int64?,
        size: Int,
        categoryId: Int64,
        season: Set<Season>
    ) async throws -> (content: [HomeClothEntity], isLast: Bool)
    
    /// 오늘의 코디 생성
    func createTodayCoordinate(request: CreateTodayCoordinateRequestDTO) async throws -> TodayCoordinateEntity
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinateClothes() async throws -> [TodayCoordinateClothEntity]
    
    /// 기존 api
    
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
