//
//  HomeEntity.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import Foundation

// MARK: - Home
struct HomeEntity {
    let title: String
}

// MARK: - Weather
struct WeatherData {
    var currentTemp: Int
    var symbolName: String
    let dailyForecasts: [DailyWeather]
    let locationName: String
}

struct DailyWeather {
    let highTemperature: Int
    let lowTemperature: Int
}

// MARK: - Date
struct DateEntity {
    let formattedDate: String
}

// MARK: - LookBook BottomSheet Entity
struct LookBookBottomSheetEntity: Identifiable, Codable {
    let lookbookId: Int64
    let imageUrl: String
    let title: String
    let count: Int64

    var id: Int64 { lookbookId }

    private enum CodingKeys: String, CodingKey {
        case lookbookId, imageUrl, title, count
    }
}

// MARK: - Cloth Tag Entity
struct ClothTagEntity: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let content: String
    var locationX: CGFloat
    var locationY: CGFloat
//    var isRightSide: Bool = true
}
