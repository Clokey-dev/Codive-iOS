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
    let imageURL: String? = nil
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

// MARK: - Cloth List Request DTO
struct ClothListRequestDTO {
    let lastClothId: Int64?
    let size: Int
    let categoryId: Int64?
    let season: String?
    
    func toQueryParameters() -> [String: String] {
        var params: [String: String] = [:]
        
        if let lastClothId = lastClothId {
            params["lastClothId"] = String(lastClothId)
        }
        params["size"] = String(size)
        if let categoryId = categoryId {
            params["categoryId"] = String(categoryId)
        }
        if let season = season {
            params["season"] = season
        }
        
        return params
    }
}

// MARK: - Cloth List Response DTO
struct ClothListResponseDTO: Codable {
    let clothId: Int64
    let clothImageUrl: String
}

// MARK: - DTO to Entity Mapping
extension ClothListResponseDTO {
    func toEntity(categoryId: Int) -> HomeClothEntity {
        return HomeClothEntity(
            id: Int(clothId),
            categoryId: categoryId,
            imageUrl: clothImageUrl
        )
    }
}

// MARK: - Multiple Response Mapping
extension Array where Element == ClothListResponseDTO {
    func toEntities(categoryId: Int) -> [HomeClothEntity] {
        return self.map { $0.toEntity(categoryId: categoryId) }
    }
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

// MARK: - LookBook Bottom Sheet Entity

/// 룩북 선택 바텀시트에 표시될 항목 정보를 담는 엔티티
// MARK: - LookBook BottomSheet Entity
struct LookBookBottomSheetEntity: Identifiable, Codable {
    var id = UUID()
    let lookbookId: Int
    let codiId: Int
    let imageUrl: String
    let title: String
    let count: Int
}
