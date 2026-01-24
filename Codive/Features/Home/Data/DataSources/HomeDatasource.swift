//
//  HomeDatasource.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import Foundation
import WeatherKit
import CoreLocation

protocol HomeDatasourceProtocol {
    func fetchRecommendCategoryCloth(
        lastClothId: Int64?,
        size: Int,
        categoryId: Int64,
        season: Set<Season>
    ) async throws -> (content: [HomeClothEntity], isLast: Bool)
    
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws
    
    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO
}

final class HomeDatasource: HomeDatasourceProtocol {
    
    // MARK: - Properties
    private let service = WeatherService.shared
    private let locationService: LocationService
    
    private var cachedLocation: CLLocation?
    
    private let apiService: HomeAPIServiceProtocol
    
    // MARK: - Initializer
    init(
        locationService: LocationService,
        apiService: HomeAPIServiceProtocol = HomeAPIService()
    ) {
        self.locationService = locationService
        self.apiService = apiService
    }
    
    // MARK: - 날씨 및 위치
    
    // 위치
    private func geocodeLocation(_ location: CLLocation) async -> String {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                return "알 수 없는 위치"
            }
            
            let province = placemark.administrativeArea ?? ""
            let city = placemark.locality ?? ""
            let district = placemark.subLocality ?? ""
            
            var locationComponents: [String] = []
            
            if province.contains("특별시") || province.contains("광역시") {
                locationComponents.append(province)
                if !district.isEmpty {
                    locationComponents.append(district)
                }
            } else {
                if !province.isEmpty {
                    locationComponents.append(province)
                }
                if !city.isEmpty && city != province {
                    locationComponents.append(city)
                }
                if !district.isEmpty {
                    locationComponents.append(district)
                }
            }
            
            if !locationComponents.isEmpty {
                return locationComponents.joined(separator: " ")
            } else {
                return "현재 위치"
            }
        } catch {
            print("Geocoding failed:", error.localizedDescription)
            return "위치 정보 오류"
        }
    }
    
    // 날씨
    func fetchWeatherData(for location: CLLocation?) async throws -> WeatherData {
        
        let targetLocation: CLLocation
        
        if let loc = location {
            targetLocation = loc
        } else {
            targetLocation = try await locationService.getCurrentLocation()
            self.cachedLocation = targetLocation
        }
        
        let locationName = await geocodeLocation(targetLocation)
        let weather = try await service.weather(for: targetLocation)
        
        let current = weather.currentWeather
        let currentTemp = Int(current.temperature.converted(to: .celsius).value)
        let symbolName = current.symbolName
        
        let dailyForecasts = weather.dailyForecast.prefix(1).map { day in
            DailyWeather(
                highTemperature: Int(day.highTemperature.converted(to: .celsius).value),
                lowTemperature: Int(day.lowTemperature.converted(to: .celsius).value)
            )
        }
        
        let weatherData = WeatherData(
            currentTemp: currentTemp,
            symbolName: symbolName,
            dailyForecasts: Array(dailyForecasts),
            locationName: locationName
        )
        
        return weatherData
    }
    
    // 오늘의 날짜
    func fetchToday() -> DateEntity {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        
        let todayString = formatter.string(from: Date())
        return DateEntity(formattedDate: todayString)
    }
    
    // MARK: - 코디가 없는 경우의 Home 관련
    
    /// 날씨에 따른 카테고리별 옷 리스트 - API 연결
    func fetchRecommendCategoryCloth(
        lastClothId: Int64?,
        size: Int,
        categoryId: Int64,
        season seasons: Set<Season>
    ) async throws -> (content: [HomeClothEntity], isLast: Bool) {
        let result = try await apiService.fetchRecommendCategoryCloth(
            lastClothId: lastClothId.map { Int64($0) },
            size: Int32(size),
            categoryId: categoryId,
            season: Array(seasons)
        )
        
        return (
            content: result.content.map { $0.toEntity(categoryId: categoryId) },
            isLast: result.isLast
        )
    }
    
    /// 오늘의 날씨 보내기
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws {
        try await apiService.postTodayTemp(request: request)
    }
    
    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO {
        return try await apiService.fetchNotificationExist()
    }
}

extension HomeDatasource {
    // 오늘의 코디 추가하기
    func createTodayDailyCodi(_ entity: TodayDailyCodi) async throws {

        let requestDTO = CodiCoordinateRequestDTO(
            coordinateImageUrl: entity.coordinateImageUrl,
            Payload: entity.payloads.map {
                CodiCoordinatePayloadDTO(
                    clothId: Int64($0.clothId),
                    locationX: $0.locationX,
                    locationY: $0.locationY,
                    ratio: $0.ratio,
                    degree: Double($0.degree),
                    order: $0.order
                )
            }
        )

        try await saveCodiCoordinate(requestDTO)
    }
    
    // MARK: - Categorory 수정 뷰 관련
    /// 카테고리 별 개수
    func loadCategories() -> [CategoryEntity] {
        if let savedCategories = UserDefaults.standard.data(forKey: "SavedCategories"),
           let decoded = try? JSONDecoder().decode([CategoryEntity].self, from: savedCategories) {
            return decoded
        }

        return [
            CategoryEntity(id: 1, title: "상의", itemCount: 2),
            CategoryEntity(id: 2, title: "바지", itemCount: 1),
            CategoryEntity(id: 3, title: "스커트", itemCount: 0),
            CategoryEntity(id: 4, title: "아우터", itemCount: 0),
            CategoryEntity(id: 5, title: "신발", itemCount: 1),
            CategoryEntity(id: 6, title: "가방", itemCount: 0),
            CategoryEntity(id: 7, title: "패션 소품", itemCount: 0)
        ]
    }
    
    /// 카테고리 적용하기
    func saveCategories(_ categories: [CategoryEntity]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "SavedCategories")
        }
        print("저장 완료:")
        categories.forEach { print("\($0.id): \($0.title): \($0.itemCount)") }
    }

    // MARK: - 코디보드
    // 코디 추가하기
    func saveCodiCoordinate(_ request: CodiCoordinateRequestDTO) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)

        for (index, item) in request.Payload.enumerated() {
            print("""
            [Item \(index)] 
              - clothId: \(item.clothId)
              - position: (\(item.locationX), \(item.locationY))
              - ratio(scale): \(item.ratio)
              - degree: \(item.degree)
              - order: \(item.order)
            """)
        }
    }
    
    // 코디보드 옷 불러오기
    func loadInitialImages() -> [DraggableImageEntity] {
        return [
            DraggableImageEntity(id: 1, name: "image1", position: CGPoint(x: 80, y: 80), scale: 1.0, rotationAngle: 0.0),
            DraggableImageEntity(id: 2, name: "image2", position: CGPoint(x: 160, y: 120), scale: 1.0, rotationAngle: 0.0),
            DraggableImageEntity(id: 3, name: "image3", position: CGPoint(x: 240, y: 160), scale: 1.0, rotationAngle: 0.0),
            DraggableImageEntity(id: 4, name: "image4", position: CGPoint(x: 120, y: 240), scale: 1.0, rotationAngle: 0.0),
            DraggableImageEntity(id: 5, name: "image5", position: CGPoint(x: 200, y: 280), scale: 1.0, rotationAngle: 0.0),
            DraggableImageEntity(id: 6, name: "image6", position: CGPoint(x: 250, y: 240), scale: 1.0, rotationAngle: 0.0)
        ]
    }
    
    // MARK: - 코디가 있는 경우의 Home 관련
    // 코디 불러오기
    func loadDummyCodiItems() -> [CodiItemEntity] {
        return [
            CodiItemEntity(
                id: 1,
                imageName: "image1",
                clothName: "시계",
                brandName: "apple",
                description: "사계절 착용 가능한 시계",
                x: 300,
                y: 100,
                width: 70,
                height: 70
            ),
            CodiItemEntity(
                id: 2,
                imageName: "image4",
                clothName: "체크 셔츠",
                brandName: "Polo",
                description: "사계절 착용 가능한 셔츠",
                x: 100,
                y: 100,
                width: 70,
                height: 70
            ),
            CodiItemEntity(
                id: 3,
                imageName: "image3",
                clothName: "와이드 치노 팬츠",
                brandName: "Basic Concept",
                description: "사계절 착용 가능한 면 바지",
                x: 300,
                y: 200,
                width: 100,
                height: 100
            )
        ]
    }
    
    // 룩북에 추가 바텀시트 더미데이터
    func fetchLookBookList() async throws -> [LookBookBottomSheetEntity] {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return [
            LookBookBottomSheetEntity(lookbookId: 1, codiId: 101, imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800", title: "운동룩", count: 6),
            LookBookBottomSheetEntity(lookbookId: 2, codiId: 102, imageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800", title: "출근룩", count: 12),
            LookBookBottomSheetEntity(lookbookId: 3, codiId: 103, imageUrl: "https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=800", title: "데이트룩", count: 16)
        ]
    }
}
