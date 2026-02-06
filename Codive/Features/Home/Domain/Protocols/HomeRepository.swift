//
//  HomeRepository.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import CoreLocation
import CodiveAPI

protocol HomeRepository {
    // MARK: - 날씨
    
    func fetchWeatherData(for location: CLLocation?) async throws -> WeatherData
    
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws
    
    func uploadCodiImage(jpgData: Data) async throws -> String
    
    // MARK: - 코디가 없는 경우의 Home 관련
    
    /// 날씨에 따른 카테고리별 옷 리스트 api 연결
    func fetchRecommendCategoryClothList(
        lastClothId: Int64?,
        size: Int32,
        categoryId: Int64,
        season: Set<Season>
    ) async throws -> (content: [HomeClothEntity], isLast: Bool)
    
    /// 오늘의 코디 생성
    func createTodayCoordinate(request: CreateTodayCoordinateRequestDTO) async throws -> TodayCoordinateEntity
    
    // 룩북 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> (content: [LookBookEntity], isLast: Bool)

    // MARK: - 코디가 있는 경우의 Home 관련
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinatePreview() async throws -> FetchTodayCoordinatePreviewResponseDTO
    
    func fetchTodayCoordinateDetails() async throws -> [FetchTodayCoordinateDetailsResponseDTO]
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws
    
    /// 이전 일일 코디로 자동 생성
    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> AutoDailyCoordinateEntity
    
    func getToday() -> DateEntity
    
    // MARK: - 카테고리 수정 관련
    
    func fetchCategories() -> [CategoryEntity]
    func saveCategories(_ categories: [CategoryEntity])
}
