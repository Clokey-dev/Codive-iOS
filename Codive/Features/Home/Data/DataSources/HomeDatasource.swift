//
//  HomeDatasource.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import Foundation
import WeatherKit
import CoreLocation
import CodiveAPI

protocol HomeDatasourceProtocol {
    /// 계절에 따른 카테고리별 옷 리스트
    func fetchRecommendCategoryCloth(
        lastClothId: Int64?,
        size: Int32,
        categoryId: Int64,
        season: Set<Season>
    ) async throws -> HomeCategoryResponseDTO
    
    /// 오늘의 온도 알림
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws
    
    /// 오늘의 코디 생성
    func createTodayCoordinate(request: CreateTodayCoordinateRequestDTO) async throws -> CreateTodayCoordinateResponseDTO
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinatePreview() async throws -> FetchTodayCoordinatePreviewResponseDTO
    
    func fetchTodayCoordinateDetails() async throws -> [FetchTodayCoordinateDetailsResponseDTO]
    
    /// 룩북 전체 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws
    
    /// 이전 일일 코디로 자동 생성
    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> CreateAutoDailyCoordinateAPIResponseDTO
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
        size: Int32,
        categoryId: Int64,
        season seasons: Set<Season>
    ) async throws -> HomeCategoryResponseDTO {
        return try await apiService.fetchRecommendCategoryCloth(
            lastClothId: lastClothId,
            size: size,
            categoryId: categoryId,
            season: Array(seasons)
        )
    }
    
    /// 오늘의 날씨 보내기
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws {
        try await apiService.postTodayTemp(request: request)
    }
    
    /// 오늘의 코디 생성
    func createTodayCoordinate(request: CreateTodayCoordinateRequestDTO) async throws -> CreateTodayCoordinateResponseDTO {
        return try await apiService.createTodayCoordinate(request: request)
    }
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinatePreview() async throws -> FetchTodayCoordinatePreviewResponseDTO {
        return try await apiService.fetchTodayCoordinatePreview()
    }
    
    func fetchTodayCoordinateDetails() async throws -> [FetchTodayCoordinateDetailsResponseDTO] {
        return try await apiService.fetchTodayCoordinateDetails()
    }
    
    /// 룩북 전체 리스트 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO {
        return try await apiService.fetchLookBookList(
            lastLookBookId: lastLookBookId,
            size: size,
            direction: direction
        )
    }
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws {
        try await apiService.patchUpdateCoordinates(coordinateId: coordinateId, request: request)
    }
    
    /// 코디 이미지를 S3에 업로드하고 최종 URL을 반환
    func uploadCodiImage(jpgData: Data) async throws -> String {
        let presignedUrlInfos = try await apiService.getPresignedUrls(for: [jpgData])
        
        guard let urlInfo = presignedUrlInfos.first else {
            throw LookBookAPIError.uploadFailed(message: "Presigned URL 발급 실패")
        }
        
        try await uploadImageToS3(
            presignedUrl: urlInfo.presignedUrl,
            imageData: jpgData,
            md5Hash: urlInfo.md5Hash
        )

        return urlInfo.finalUrl
    }
    
    /// 이전 일일 코디로 자동 생성
    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> CreateAutoDailyCoordinateAPIResponseDTO {
        return try await apiService.createAutoDailyCoordinate(request: request)
    }
 
    private func uploadImageToS3(
        presignedUrl: String,
        imageData: Data,
        md5Hash: String
    ) async throws {
        guard let url = URL(string: presignedUrl) else {
            throw LookBookAPIError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue(md5Hash, forHTTPHeaderField: "Content-MD5")
        request.httpBody = imageData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LookBookAPIError.uploadFailed(message: "S3 업로드 실패 (Status: \((response as? HTTPURLResponse)?.statusCode ?? -1))")
        }
        
        print("✅ S3 이미지 업로드 성공")
    }
}

extension HomeDatasource {
    // MARK: - Categorory 수정 뷰 관련
    /// 카테고리 별 개수
    func loadCategories() -> [CategoryEntity] {
        if let savedCategories = UserDefaults.standard.data(forKey: "SavedCategories"),
           let decoded = try? JSONDecoder().decode([CategoryEntity].self, from: savedCategories) {
            return decoded
        }

        return [
            CategoryEntity(id: 1, title: "상의", itemCount: 1),
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
    
    // MARK: - 코디가 있는 경우의 Home 관련
    
}
