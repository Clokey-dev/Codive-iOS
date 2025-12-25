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

// MARK: - Category
struct CategoryEntity: Identifiable, Codable {
    let id: Int
    let title: String
    var itemCount: Int
}

// MARK: - Home Cloth
struct HomeClothEntity: Identifiable, Codable {
    let id: Int
    let categoryId: Int
    let imageUrl: String
}

// MARK: - Draggable Image
struct DraggableImageEntity: Identifiable, Hashable {
    let id: Int
    let name: String
    var position: CGPoint
    var scale: CGFloat
    var rotationAngle: Double
}

// MARK: - Codi Coordinate Request (for server)
struct CodiCoordinateRequestDTO: Codable {
    let coordinateImageUrl: String
    let Payload: [CodiCoordinatePayloadDTO]
}

struct CodiCoordinatePayloadDTO: Codable {
    let clothId: Int64
    let locationX: Double
    let locationY: Double
    let ratio: Double
    let degree: Double
    let order: Int
}

// MARK: - Codi Item
struct CodiItemEntity: Identifiable {
    let id: Int
    let imageName: String
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

// MARK: - Date
struct DateEntity {
    let formattedDate: String
}
