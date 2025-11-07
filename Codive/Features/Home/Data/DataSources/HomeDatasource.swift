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
}
