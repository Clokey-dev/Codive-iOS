//
//  HomeDatasource.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import Foundation
import WeatherKit
import CoreLocation

final class HomeDatasource {
    
    // MARK: - Properties
    private let service = WeatherService.shared
    private let locationService: LocationService
    
    private var cachedLocation: CLLocation?
    
    // MARK: - Initializer
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    // MARK: - Location & Geocoding
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
    
    // MARK: - Weather Data Fetching
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
    
    // MARK: - Categories
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
    
    func saveCategories(_ categories: [CategoryEntity]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "SavedCategories")
        }
        print("저장 완료:")
        categories.forEach { print("\($0.id): \($0.title): \($0.itemCount)") }
    }
    
    // MARK: - Cloth Items (API Mock)
    func fetchClothItems(request: ClothListRequestDTO) async throws -> [ClothListResponseDTO] {
        print("===== 🔵 Cloth List Request Mock =====")
        print("Request Parameters:", request.toQueryParameters())
        
        // 카테고리 ID에 따라 다른 데이터를 반환
        let categoryId = request.categoryId ?? 1
        let mockResponse: [ClothListResponseDTO]
        
        switch categoryId {
        case 1: // 상의
            mockResponse = [
                ClothListResponseDTO(clothId: 101, clothImageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800"), // 흰 티셔츠
                ClothListResponseDTO(clothId: 102, clothImageUrl: "https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=800")  // 셔츠
            ]
//        case 2: // 바지
//            mockResponse = [
//                ClothListResponseDTO(clothId: 201, clothImageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800"), // 청바지
//                ClothListResponseDTO(clothId: 202, clothImageUrl: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=800")  // 슬랙스
//            ]
//        case 3: // 바지
//            mockResponse = [
//                ClothListResponseDTO(clothId: 201, clothImageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800"), // 청바지
//                ClothListResponseDTO(clothId: 202, clothImageUrl: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=800")  // 슬랙스
//            ]
//        case 4: // 바지
//            mockResponse = [
//                ClothListResponseDTO(clothId: 201, clothImageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800"), // 청바지
//                ClothListResponseDTO(clothId: 202, clothImageUrl: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=800")  // 슬랙스
//            ]
//        case 5: // 신발
//            mockResponse = [
//                ClothListResponseDTO(clothId: 501, clothImageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800"), // 빨간 운동화
//                ClothListResponseDTO(clothId: 502, clothImageUrl: "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800")  // 갈색 구두
//            ]
//        case 6: // 바지
//            mockResponse = [
//                ClothListResponseDTO(clothId: 201, clothImageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800"), // 청바지
//                ClothListResponseDTO(clothId: 202, clothImageUrl: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=800")  // 슬랙스
//            ]
//        case 7: // 바지
//            mockResponse = [
//                ClothListResponseDTO(clothId: 201, clothImageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800"), // 청바지
//                ClothListResponseDTO(clothId: 202, clothImageUrl: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=800")  // 슬랙스
//            ]
        default:
            // 나머지 카테고리는 빈 배열 혹은 기본 이미지 반환
            mockResponse = [
//                ClothListResponseDTO(clothId: Int64(categoryId * 100), clothImageUrl: "https://images.unsplash.com/photo-1584735175315-9d5df23860b1?w=800")
            ]
        }
        
        print("Response Count for Category \(categoryId):", mockResponse.count)
        print("===== ✅ Mock response complete =====")
        
        return mockResponse
    }
    
    func loadClothItems() -> [HomeClothEntity] {
        // 기존 메서드는 유지 (하위 호환성)
        return [
            HomeClothEntity(
                id: 1,
                categoryId: 1,
                imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800"
            ),
            HomeClothEntity(
                id: 2,
                categoryId: 1,
                imageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800"
            ),
            HomeClothEntity(
                id: 3,
                categoryId: 2,
                imageUrl: "https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=800"
            ),
            HomeClothEntity(
                id: 4,
                categoryId: 5,
                imageUrl: "https://images.unsplash.com/photo-1584735175315-9d5df23860b1?w=800"
            )
        ]
    }
    
    // MARK: - Codi Items
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

    // MARK: - Codi Items (API Mock)
    func saveCodiCoordinate(_ request: CodiCoordinateRequestDTO) async throws {
        
        print("===== 📦 Codi Coordinate Request Mock (Server API Call) =====")
        print("Snapshot Image URL: \(request.coordinateImageUrl)")
        print("Total Items: \(request.Payload.count)")
        
        // 네트워크 지연 시뮬레이션
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
        
        print("===== ✅ Mock Server Response: Success =====")
    }
    
    func loadDummyCodiItems() -> [CodiItemEntity] {
        return [
            // 상의 (왼쪽 위 근처)
            CodiItemEntity(
                id: 1,
                imageName: "image1",
                clothName: "시계",
                brandName: "apple",
                description: "사계절 착용 가능한 시계",
                x: 300,   // ← 캔버스 가로의 약 25%
                y: 100,   // ← 세로의 약 25%
                width: 70,
                height: 70
            ),
            // 상의 (왼쪽 위 근처)
            CodiItemEntity(
                id: 2,
                imageName: "image4",
                clothName: "체크 셔츠",
                brandName: "Polo",
                description: "사계절 착용 가능한 셔츠",
                x: 100,   // ← 캔버스 가로의 약 25%
                y: 100,   // ← 세로의 약 25%
                width: 70,
                height: 70
            ),
            // 바지 (오른쪽 중간쯤)
            CodiItemEntity(
                id: 3,
                imageName: "image3",
                clothName: "와이드 치노 팬츠",
                brandName: "Basic Concept",
                description: "사계절 착용 가능한 면 바지",
                x: 300,  // ← 가로 75%
                y: 200,  // ← 세로 35% 근처
                width: 100,
                height: 100
            ),
            // 신발 (왼쪽 아래 근처)
            CodiItemEntity(
                id: 4,
                imageName: "image2",
                clothName: "Dr.Martens",
                brandName: "Codive Studio",
                description: "구두",
                x: 150,  // ← 가로 35% 근처
                y: 300,  // ← 세로 75%
                width: 90,
                height: 90
            ),
            CodiItemEntity(
                id: 5,
                imageName: "image5",
                clothName: "??",
                brandName: "??",
                description: "사계절 착용 가능한 ??",
                x: 200,   // ← 캔버스 가로의 약 25%
                y: 200,   // ← 세로의 약 25%
                width: 100,
                height: 100
            )
        ]
    }
    
    // MARK: - Date Handling
    func fetchToday() -> DateEntity {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        
        let todayString = formatter.string(from: Date())
        return DateEntity(formattedDate: todayString)
    }
    
    // MARK: - LookBook (API Mock)
    func fetchLookBookList() async throws -> [LookBookBottomSheetEntity] {
        // 네트워크 지연 시뮬레이션
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return [
            LookBookBottomSheetEntity(lookbookId: 1, codiId: 101, imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800", title: "운동룩", count: 6),
            LookBookBottomSheetEntity(lookbookId: 2, codiId: 102, imageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800", title: "출근룩", count: 12),
            LookBookBottomSheetEntity(lookbookId: 3, codiId: 103, imageUrl: "https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=800", title: "데이트룩", count: 16)
        ]
    }
}
