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
    
    /// WeatherKit을 이용해 날씨 데이터를 불러와 `WeatherData`로 변환합니다.
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
}
