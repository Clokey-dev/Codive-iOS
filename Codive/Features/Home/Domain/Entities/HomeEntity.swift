//
//  HomeEntity.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import Foundation

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

struct CategoryEntity: Identifiable {
    let id: Int
    let title: String
    var itemCount: Int
}

struct DraggableImageEntity: Identifiable {
    let id: Int
    let name: String
    var position: CGPoint
    var scale: CGFloat
    var rotationAngle: Double 
}

struct CodiItemEntity: Identifiable {
    let id: Int
    let imageName: String
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

struct DateEntity {
    let formattedDate: String
}
