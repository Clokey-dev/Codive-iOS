//
//  HomeEntity.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

struct HomeEntity {
    let title: String
}

struct WeatherData {
    var currentTemp: Int
    var symbolName: String
    let dailyForecasts: [DailyWeather]
}

struct DailyWeather {
    let highTemperature: Int
    let lowTemperature: Int
}

struct CategoryEntity: Identifiable{
    let id: Int
    let title: String
    var itemCount: Int
}
