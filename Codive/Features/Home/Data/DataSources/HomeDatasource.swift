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
            
            // 도/특별시/광역시 + 시/군 + 구 형식으로 조합
            var locationComponents: [String] = []
            
            if !province.isEmpty {
                locationComponents.append(province)
            }
            if !city.isEmpty {
                locationComponents.append(city)
            }
            if !district.isEmpty {
                locationComponents.append(district)
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
            // MARK: - 수정: 위치 이름을 추가합니다.
            locationName: locationName
        )
        
        return weatherData
    }
    
    // MARK: - Categories
    func loadCategories() -> [CategoryEntity] {
        return [
            CategoryEntity(id: 1, title: "상의", itemCount: 0),
            CategoryEntity(id: 2, title: "바지", itemCount: 0),
            CategoryEntity(id: 3, title: "스커트", itemCount: 0),
            CategoryEntity(id: 4, title: "아우터", itemCount: 0),
            CategoryEntity(id: 5, title: "신발", itemCount: 0),
            CategoryEntity(id: 6, title: "가방", itemCount: 0),
            CategoryEntity(id: 7, title: "패션 소품", itemCount: 0)
        ]
    }
    
    func saveCategories(_ categories: [CategoryEntity]) {
        print("저장 완료:")
        categories.forEach { print("\($0.id): \($0.title): \($0.itemCount)") }
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
    
    func saveCodiItems(_ images: [DraggableImageEntity]) {
        print("코디 저장 완료 (\(images.count)개)")
        for image in images {
            let pos = "pos: (\(Int(image.position.x)), \(Int(image.position.y)))"
            let scaleStr = "scale: \(String(format: "%.2f", image.scale))"
            let rotStr = "rotation: \(String(format: "%.2f", image.rotationAngle))°"
            print("• \(image.name) →", pos + ",", scaleStr + ",", rotStr)
        }
    }
    
    func loadDummyCodiItems() -> [CodiItemEntity] {
        return [
            CodiItemEntity(id: 1, imageName: "image1", x: 80, y: 80, width: 80, height: 80),
            CodiItemEntity(id: 2, imageName: "image2", x: 160, y: 120, width: 90, height: 90),
            CodiItemEntity(id: 3, imageName: "image3", x: 240, y: 160, width: 100, height: 100),
            CodiItemEntity(id: 4, imageName: "image4", x: 120, y: 240, width: 70, height: 70),
            CodiItemEntity(id: 5, imageName: "image5", x: 200, y: 280, width: 120, height: 120),
            CodiItemEntity(id: 6, imageName: "image6", x: 250, y: 240, width: 110, height: 110)
        ]
    }
    
    // MARK: - Date Handling
    func fetchToday() -> DateEntity {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        
        let todayString = formatter.string(from: Date())
        return DateEntity(formattedDate: todayString)
    }
}
