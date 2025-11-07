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
    
    private let service = WeatherService.shared
    
    /// WeatherKit을 이용해 날씨 데이터를 불러와 `WeatherData`로 변환
    func fetchWeatherData(for location: CLLocation) async throws -> WeatherData {
        // WeatherKit에서 날씨 데이터 가져오기
        let weather = try await service.weather(for: location)
        
        // 현재 온도 및 상태 아이콘 정보 추출
        let current = weather.currentWeather
        let currentTemp = Int(current.temperature.converted(to: .celsius).value)
        let symbolName = current.symbolName
        
        // 일별 예보 정보 변환 (최대 5일치 정도만 가져오는 예시)
        let dailyForecasts = weather.dailyForecast.prefix(5).map { day in
            DailyWeather(
                highTemperature: Int(day.highTemperature.converted(to: .celsius).value),
                lowTemperature: Int(day.lowTemperature.converted(to: .celsius).value)
            )
        }
        
        // WeatherData 모델에 담아서 반환
        let weatherData = WeatherData(
            currentTemp: currentTemp,
            symbolName: symbolName,
            dailyForecasts: Array(dailyForecasts)
        )
        
        return weatherData
    }
    
    // 카테고리 불러오기
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
    
    // 카테고리 저장
    func saveCategories(_ categories: [CategoryEntity]) {
        print("저장 완료:")
        categories.forEach { print("\($0.id): \($0.title): \($0.itemCount)") }
    }
    
    // 이미지 로드
    func loadInitialImages() -> [DraggableImageEntity] {
        return [
            DraggableImageEntity(id: 1, name: "image1", position: CGPoint(x: 80, y: 80), scale: 1.0),
            DraggableImageEntity(id: 2, name: "image2", position: CGPoint(x: 160, y: 120), scale: 1.0),
            DraggableImageEntity(id: 3, name: "image3", position: CGPoint(x: 240, y: 160), scale: 1.0),
            DraggableImageEntity(id: 4, name: "image4", position: CGPoint(x: 120, y: 240), scale: 1.0),
            DraggableImageEntity(id: 5, name: "image5", position: CGPoint(x: 200, y: 280), scale: 1.0),
            DraggableImageEntity(id: 6, name: "image6", position: CGPoint(x: 250, y: 240), scale: 1.0)
        ]
    }
    
    // 코디 완성 시 이미지 정보 + 크기 전달
    func saveCodiResult(_ images: [DraggableImageEntity]) {
        print("코디 저장 완료 (\(images.count)개)")
        for image in images {
            print("• \(image.name) → pos: (\(Int(image.position.x)), \(Int(image.position.y))), scale: \(String(format: "%.2f", image.scale))")
        }
    }
    
    func loadDummyCodiItems() -> [CodiItemEntity] {
        return [
            CodiItemEntity(id: 1, imageName: "image1", x: 80, y: 80,  width: 80, height: 80),
            CodiItemEntity(id: 2, imageName: "image2", x: 160, y: 120,  width: 90, height: 90),
            CodiItemEntity(id: 3, imageName: "image3", x: 240, y: 160, width: 100, height: 100),
            CodiItemEntity(id: 4, imageName: "image4", x: 120, y: 240, width: 70, height: 70),
            CodiItemEntity(id: 5, imageName: "image5", x: 200, y: 280, width: 120, height: 120),
            CodiItemEntity(id: 6, imageName: "image6", x: 250, y: 240, width: 110, height: 110),
        ]
    }
}
